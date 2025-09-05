from django.http import JsonResponse
from rest_framework import serializers

from api.models import Attendance, LiveSession, SeatReservation
from .models_academics import Course, Module, Lesson, LessonAsset

class CourseSer(serializers.ModelSerializer):
    class Meta: model = Course; fields = "__all__"; read_only_fields = ("org",)

class ModuleSer(serializers.ModelSerializer):
    class Meta: model = Module; fields = "__all__"; read_only_fields = ("org",)

class LessonSer(serializers.ModelSerializer):
    class Meta: model = Lesson; fields = "__all__"; read_only_fields = ("org",)

class AssetSer(serializers.ModelSerializer):
    class Meta: model = LessonAsset; fields = "__all__"; read_only_fields = ("org","ready","size_bytes","duration_seconds")



class LiveSessionSer(serializers.ModelSerializer):
    class Meta: model = LiveSession; fields = "__all__"

class SeatReservationSer(serializers.ModelSerializer):
    class Meta: model = SeatReservation; fields = "__all__"

class AttendanceSer(serializers.ModelSerializer):
    class Meta: model = Attendance; fields = "__all__"







class JoinResponseSer(serializers.Serializer):
    session_id = serializers.IntegerField()
    user_id = serializers.IntegerField()
    joined_at = serializers.DateTimeField()
    message = serializers.CharField(default="Joined successfully")

class LeaveResponseSer(serializers.Serializer):
    session_id = serializers.IntegerField()
    user_id = serializers.IntegerField()
    left_at = serializers.DateTimeField()
    duration_seconds = serializers.IntegerField()
    message = serializers.CharField(default="Left successfully")