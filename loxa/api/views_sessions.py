# api/views_sessions.py
import time
from django.conf import settings
from django.utils import timezone
from django_filters import rest_framework as dj_filters
from rest_framework import viewsets, permissions, response, status, filters
from rest_framework.decorators import action
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend  # type: ignore

from django.contrib.auth import authenticate, login, logout

from .models import LiveSession, Attendance, SeatReservation
from .serializers import (
    LiveSessionSerializer,
    JoinResponseSer, LeaveResponseSer,
    SeatReservationSer, AttendanceSer,
)
from .permissions import IsSessionModeratorOrOwner

from agora_token_builder import RtcTokenBuilder


# ---------- Agora helpers ----------
ROLE_PUBLISHER = 1   # host/broadcaster
ROLE_SUBSCRIBER = 2
MAX_UID = (1 << 31) - 1
def _uid_for(user):  # deterministic int32
    return int(user.id) % MAX_UID


# ---------- Throttles ----------
class TokenThrottle(ScopedRateThrottle):
    scope = "agora_token"

class SessionJoinThrottle(ScopedRateThrottle):
    scope = "session_join"




class LiveSessionFilter(dj_filters.FilterSet):
    owner = dj_filters.CharFilter(method='filter_owner')  # "me" or user id

    class Meta:
        model = LiveSession
        fields = ["org", "owner"]

    def filter_owner(self, queryset, name, value):
        # owner=me → current user
        if value == "me":
            return queryset.filter(owner=self.request.user) # type: ignore
        # owner=<id> → numeric id
        try:
            return queryset.filter(owner_id=int(value))
        except (TypeError, ValueError):
            return queryset.none()



# ---------- Live Sessions ----------
class LiveSessionViewSet(viewsets.ModelViewSet):

    queryset = LiveSession.objects.select_related("org", "owner").all()
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = LiveSessionSerializer

    # 🧩 filters / ordering / search
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_class = LiveSessionFilter
    ordering_fields = ["start_time", "title", "id"]
    ordering = ["-start_time"]
    search_fields = ["title"]

    # 🧩 ?owner=me support
    def get_queryset(self):
        qs = super().get_queryset()
        owner = self.request.query_params.get("owner")
        if owner == "me":
            qs = qs.filter(owner=self.request.user)
        ordering = self.request.query_params.get("ordering")
        if ordering:
            field = ordering.lstrip("-")
            desc = ordering.startswith("-")
            if field == "created_at":
                field = "start_time"
            if field in {"start_time", "title", "id"}:
                qs = qs.order_by(f"{'-' if desc else ''}{field}")
        return qs

    # 🧩 auto channel_name on create
    def perform_create(self, serializer):
        user = self.request.user
        org = getattr(self.request, "org", None)

        # (option) user ရဲ့ org attribute ရှိရင် default
        if org is None and hasattr(user, "org"):
            org = getattr(user, "org")

        base = (self.request.data.get("title") or "session").lower().replace(" ", "-") # type: ignore
        channel = f"{base}-{int(timezone.now().timestamp())}"

        # org field က model မှာ null=True မဟုတ်ရင် ⇒ org မရှိရင် 400 ပြန်ချင်ရင် အောက်လို
        # if org is None:
        #     raise ValidationError({"org": "This field is required."})

        save_kwargs = dict(owner=user, channel_name=channel)
        if org is not None:
            save_kwargs["org"] = org

        serializer.save(**save_kwargs)


    # ---- actions ----
    @action(detail=True, methods=["POST"], throttle_classes=[SessionJoinThrottle])
    def join(self, request, pk=None):
        sess = self.get_object()
        att, created = Attendance.objects.get_or_create(
            org=sess.org, session=sess, user=request.user,
            defaults={"joined_at": timezone.now()},
        )
        if not created and att.left_at:
            att.joined_at = timezone.now()
            att.left_at = None
            att.total_seconds = 0
            att.save(update_fields=["joined_at", "left_at", "total_seconds"])
        return response.Response({"joined": True, "attendance_id": att.id})

    @action(detail=True, methods=["POST"])
    def leave(self, request, pk=None):
        sess = self.get_object()
        try:
            att = Attendance.objects.get(org=sess.org, session=sess, user=request.user)
        except Attendance.DoesNotExist:
            return response.Response({"detail": "not joined"}, status=400)
        if not att.left_at:
            att.left_at = timezone.now()
            if att.joined_at:
                att.total_seconds = int((att.left_at - att.joined_at).total_seconds())
            att.save(update_fields=["left_at", "total_seconds"])
        return response.Response({"left": True, "total_seconds": att.total_seconds})

    @action(
        detail=True, methods=["GET"], url_path="rtc-token",
        throttle_classes=[TokenThrottle], permission_classes=[permissions.IsAuthenticated],
    )
    def rtc_token(self, request, pk=None):
        # 🧩 this MUST be INSIDE the ViewSet (previously it was top-level → 404)
        sess: LiveSession = self.get_object()
        user = request.user

        role_q = (request.query_params.get("role") or "audience").lower()
        want_host = role_q in ("host", "publisher", "broadcaster")

        # only owner/staff/superuser can publish
        is_host_allowed = (user == sess.owner) or getattr(user, "is_staff", False) or getattr(user, "is_superuser", False)
        if want_host and not is_host_allowed:
            return response.Response({"detail": "not allowed to publish"}, status=status.HTTP_403_FORBIDDEN)

        app_id = getattr(settings, "AGORA_APP_ID", "")
        app_cert = getattr(settings, "AGORA_APP_CERT", "")
        if not app_id or not app_cert:
            return response.Response({"detail": "agora creds missing"}, status=500)

        expire_at = int(time.time()) + 60 * 60  # 1 hour
        uid = _uid_for(user)
        role = ROLE_PUBLISHER if want_host else ROLE_SUBSCRIBER

        token = RtcTokenBuilder.buildTokenWithUid(app_id, app_cert, sess.channel_name, uid, role, expire_at)
        return response.Response({
            "token": token,
            "channel": sess.channel_name,
            "uid": uid,
            "role": "host" if want_host else "audience",
            "expire_at": expire_at,
            "app_id": app_id,
        })


# ---------- Moderation ----------
class LiveSessionModerationViewSet(viewsets.GenericViewSet):
    queryset = LiveSession.objects.all()
    permission_classes = [IsAuthenticated, IsSessionModeratorOrOwner]

    @action(detail=True, methods=["POST"])
    def kick(self, request, pk=None):
        user_id = request.data.get("user_id")
        if not user_id:
            return response.Response({"detail": "user_id required"}, status=400)
        return response.Response({"kicked": user_id})

    @action(detail=True, methods=["POST"])
    def mute(self, request, pk=None):
        user_id = request.data.get("user_id")
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


# ---------- Simple join/leave API (optional) ----------
class JoinSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request, *args, **kwargs):
        data = {"session_id": 1, "user_id": request.user.id, "joined_at": timezone.now()}
        return Response(JoinResponseSer(data).data)

class LeaveSessionView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request):
        data = {"session_id": 1, "user_id": request.user.id, "left_at": timezone.now(), "duration_seconds": 0}
        return Response(LeaveResponseSer(data).data)


# ---------- SeatReservation / Attendance ----------
class SeatReservationViewSet(viewsets.ModelViewSet):
    queryset = SeatReservation.objects.select_related("org", "session", "user").all()
    serializer_class = SeatReservationSer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ["org", "session", "user", "state"]
    ordering_fields = ["created_at"]
    search_fields = ["session__title", "user__username"]

    def perform_create(self, serializer):
        org = serializer.validated_data.get("org", None)
        if org is None and hasattr(self.request.user, "org"):
            serializer.save(org=self.request.user.org)  # type: ignore
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
        instance = serializer.save()
        if instance.left_at and instance.joined_at and instance.total_seconds == 0:
            delta = (instance.left_at - instance.joined_at).total_seconds()
            instance.total_seconds = max(0, int(delta))
            instance.save(update_fields=["total_seconds"])


# ---------- Session cookie login/logout for Flutter Web ----------
class SessionLoginView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        u = request.data.get("username") or request.data.get("email")
        p = request.data.get("password")
        user = authenticate(request, username=u, password=p)
        if not user:
            return Response({"detail": "invalid credentials"}, status=400)
        login(request, user)  # Set-Cookie: sessionid; csrftoken
        return Response({"ok": True, "user_id": user.id})  # type: ignore

class SessionLogoutView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        logout(request)
        return Response({"ok": True})



