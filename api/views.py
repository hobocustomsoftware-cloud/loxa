import os
from datetime import timedelta
from django.db import transaction
from django.utils import timezone
from api.mixins import OrgScopedMixin
from api.models_academics import Lesson, LessonAsset, Module
# from api.views_content import asset_fs_path
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import LiveSession, SeatReservation, Attendance
from .serializers import LiveSessionSer, JoinResponseSer, LeaveResponseSer

from drf_yasg.utils import swagger_auto_schema


AGORA_APP_ID = os.getenv("AGORA_APP_ID", "")
AGORA_APP_CERT = os.getenv("AGORA_APP_CERT", "")

# Optional: install agora_token_builder==1.0.0
# try:
#     from agora_token_builder import RtcTokenBuilder
# except Exception:
#     RtcTokenBuilder = None


class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj: LiveSession):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.owner_id == request.user.id # type: ignore


class LiveSessionViewSet(OrgScopedMixin, viewsets.ModelViewSet):
    queryset = LiveSession.objects.all().select_related("owner")
    serializer_class = LiveSessionSer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    # POST /api/sessions/  → create (owner auto = request.user)

    @action(detail=True, methods=["post"])
    def join(self, request, pk=None):
        """Reserve a seat, create attendance, and return Agora token."""
        user = request.user
        session = self.get_object()

        with transaction.atomic():
            # lock current seats to avoid overbooking
            current = (SeatReservation.objects
                    .select_for_update()
                    .filter(session=session, state__in=["PENDING","CONFIRMED"])
                    .count())
            if current >= session.max_participants:
                return Response({"detail":"Room full"}, status=status.HTTP_409_CONFLICT)

            # upsert reservation
            SeatReservation.objects.update_or_create(
                session=session, user=user,
                defaults={"state":"CONFIRMED", "expires_at": timezone.now()+timedelta(minutes=5)}
            )

            # create attendance if not exists
            Attendance.objects.get_or_create(session=session, user=user)

        # Build Agora token (fallback to dummy if builder/env missing)
        expires_at = timezone.now() + timedelta(minutes=session.duration_minutes+15)
        uid = str(user.id)
        channel = session.channel_name

        if RtcTokenBuilder and AGORA_APP_ID and AGORA_APP_CERT:
            # Role 1 = publisher
            from time import time as now
            privilege_expired_ts = int(now()) + (session.duration_minutes + 15) * 60
            rtc_token = RtcTokenBuilder.buildTokenWithUid(
                AGORA_APP_ID, AGORA_APP_CERT, channel, int(user.id), 1, privilege_expired_ts
            )
        else:
            rtc_token = f"DUMMY_{channel}_{uid}"

        payload = {"channel": channel, "uid": uid, "rtc_token": rtc_token, "expires_at": expires_at}
        return Response(JoinResponseSer(payload).data, status=200)

    @action(detail=True, methods=["post"])
    def leave(self, request, pk=None):
        """Mark attendance left_at, compute total_seconds, release seat."""
        user = request.user
        session = self.get_object()

        with transaction.atomic():
            # mark attendance
            try:
                att = Attendance.objects.select_for_update().get(session=session, user=user)
            except Attendance.DoesNotExist:
                return Response({"detail":"not joined"}, status=400)

            if not att.left_at:
                att.left_at = timezone.now()
                delta = (att.left_at - att.joined_at).total_seconds()
                att.total_seconds = int(delta) if delta > 0 else att.total_seconds
                att.save(update_fields=["left_at","total_seconds"])

            # release seat
            SeatReservation.objects.filter(session=session, user=user).update(state="RELEASEED")

        return Response(LeaveResponseSer({"ok": True}).data)
    

    @action(detail=True, methods=["post"], url_path="recording/init")
    def recording_init(self, request, pk=None):
        """
        Create (or reuse) a Lesson linked to this session, then create a RECORDING asset and
        return upload endpoint for MP4. Client will POST multipart to that endpoint.
        body: { "title": "Class A - 2025-09-03" }
        """
        org = request.org
        session = self.get_object()

        # 1) Tie a lesson to this session (create if missing)
        lesson, _ = Lesson.objects.get_or_create(
            org=org,
            live_session=session,
            defaults={
                "module": Lesson.objects.filter(org=org).first().module  # or choose properly in your UI # type: ignore
                if Lesson.objects.filter(org=org).exists() else
                Module.objects.filter(org=org).first(),                  # fallback
                "title": request.data.get("title", session.title),
                "order": 0,
            },
        )
        if not lesson.module:
            return Response({"detail":"Please create a Module first and retry."}, status=400)

        # 2) Create a RECORDING asset & return upload endpoint
        asset = LessonAsset.objects.create(org=org, lesson=lesson, type="RECORDING",
                title=request.data.get("title", session.title))
        key, _ = asset_fs_path(org.id, lesson, asset.id)  # e.g. org/..../asset/<id>/source
        asset.storage_key = key; asset.save(update_fields=["storage_key"])

        return Response({
            "asset_id": asset.id, # type: ignore
            "upload_endpoint": f"/api/assets/{asset.id}/upload/", # type: ignore
            "play_endpoint": f"/api/assets/{asset.id}/play/" # type: ignore
        })





