# api/views_sessions.py
from rest_framework.decorators import action
from rest_framework.throttling import ScopedRateThrottle
from rest_framework import viewsets, permissions, response, status
from django.utils import timezone
from rest_framework.permissions import IsAuthenticated
from .permissions import IsSessionModeratorOrOwner
from .models import LiveSession, Attendance, SeatReservation
from .serializers import JoinResponseSer, LeaveResponseSer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import viewsets, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend # type: ignore
from .models import SeatReservation, Attendance
from .serializers import SeatReservationSer, AttendanceSer

class SessionJoinThrottle(ScopedRateThrottle):
    scope = "session_join"

class SessionViewSet(viewsets.GenericViewSet):
    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [SessionJoinThrottle]

    @action(detail=True, methods=["POST"], throttle_scope="session_join")
    def join(self, request, pk=None):
        # create/update Attendance (see Phase B)
        return response.Response({"ok": True})



class LiveSessionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = LiveSession.objects.select_related("org","owner").all()
    permission_classes = [permissions.IsAuthenticated]

    class SessionJoinThrottle(ScopedRateThrottle):
        scope = "session_join"

    @action(detail=True, methods=["POST"], throttle_classes=[SessionJoinThrottle])
    def join(self, request, pk=None):
        sess = self.get_object()
        att, created = Attendance.objects.get_or_create(
            org=sess.org, session=sess, user=request.user,
            defaults={"joined_at": timezone.now()}
        )
        if not created and att.left_at:
            att.joined_at = timezone.now()
            att.left_at = None
            att.total_seconds = 0
            att.save(update_fields=["joined_at","left_at","total_seconds"])
        return response.Response({"joined": True, "attendance_id": att.id})

    @action(detail=True, methods=["POST"])
    def leave(self, request, pk=None):
        sess = self.get_object()
        try:
            att = Attendance.objects.get(org=sess.org, session=sess, user=request.user)
        except Attendance.DoesNotExist:
            return response.Response({"detail":"not joined"}, status=400)
        if not att.left_at:
            att.left_at = timezone.now()
            if att.joined_at:
                att.total_seconds = int((att.left_at - att.joined_at).total_seconds())
            att.save(update_fields=["left_at","total_seconds"])
        return response.Response({"left": True, "total_seconds": att.total_seconds})






class LiveSessionModerationViewSet(viewsets.GenericViewSet):
    queryset = LiveSession.objects.all()
    permission_classes = [IsAuthenticated, IsSessionModeratorOrOwner]

    @action(detail=True, methods=["POST"])
    def kick(self, request, pk=None):
        sess = self.get_object()
        user_id = request.data.get("user_id")
        if not user_id:
            return response.Response({"detail":"user_id required"}, status=400)
        # Signal via Channels to client of user_id to disconnect
        # channel_layer.group_send(f"sess_{sess.id}", {"type":"control", "op":"kick", "user_id":int(user_id)})
        return response.Response({"kicked": user_id})

    @action(detail=True, methods=["POST"])
    def mute(self, request, pk=None):
        sess = self.get_object()
        user_id = request.data.get("user_id")
        # channel_layer.group_send(... op="mute")
        return response.Response({"muted": user_id})

    @action(detail=True, methods=["POST"])
    def lock(self, request, pk=None):
        sess = self.get_object()
        sess.max_participants = 0
        sess.save(update_fields=["max_participants"])
        return response.Response({"locked": True})

    @action(detail=True, methods=["POST"])
    def unlock(self, request, pk=None):
        sess = self.get_object()
        new_cap = int(request.data.get("capacity", 20))
        sess.max_participants = new_cap
        sess.save(update_fields=["max_participants"])
        return response.Response({"locked": False, "capacity": new_cap})


class JoinSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request, *args, **kwargs):
        # logic here ...
        data = {"session_id": 1, "user_id": request.user.id, "joined_at": timezone.now()}
        return Response(JoinResponseSer(data).data)

class LeaveSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request):
        data = {"session_id": 1, "user_id": request.user.id, "left_at": timezone.now(), "duration_seconds": 0}
        return Response(LeaveResponseSer(data).data)





class SeatReservationViewSet(viewsets.ModelViewSet):
    queryset = SeatReservation.objects.select_related("org", "session", "user").all()
    serializer_class = SeatReservationSer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ["org", "session", "user", "state"]
    ordering_fields = ["created_at"]
    search_fields = ["session__title", "user__username"]

    def perform_create(self, serializer):
        # org မပို့လျှင် user ရဲ့ org ကို default ထည့်ပေးချင်ရင် (မရှိရင် ထားခဲ့ရုံ)
        org = serializer.validated_data.get("org", None)
        if org is None and hasattr(self.request.user, "org"):
            serializer.save(org=self.request.user.org) # type: ignore
        else:
            serializer.save()

class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.select_related("org", "session", "user").all()
    serializer_class = AttendanceSer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ["org", "session", "user"]
    ordering_fields = ["joined_at", "left_at", "total_seconds"]
    search_fields = ["session__title", "user__username"]

    def perform_update(self, serializer):
        # left_at ရိုက်လာပါက total_seconds ကို auto recalc လုပ်ထည့်ပေးချင်ရင်
        instance = serializer.save()
        if instance.left_at and instance.joined_at and instance.total_seconds == 0:
            delta = (instance.left_at - instance.joined_at).total_seconds()
            instance.total_seconds = max(0, int(delta))
            instance.save(update_fields=["total_seconds"])
