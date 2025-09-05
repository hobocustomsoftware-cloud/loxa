from rest_framework import serializers
from .models_academics import Course, Module, Lesson, LessonAsset

class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = "__all__"
        read_only_fields = ("code",)  # server auto-fills code
        # validators = []  # (optional) လုံးဝ မလိုရင် uncomment

    def create(self, validated_data):
        return Course.objects.create(**validated_data)

class ModuleSer(serializers.ModelSerializer):
    class Meta: model = Module; fields = ["id","org","course","title","order"]; read_only_fields=["org"]

class LessonSer(serializers.ModelSerializer):
    class Meta: model = Lesson; fields = ["id","org","module","title","order","live_session"]; read_only_fields=["org"]

class LessonAssetSerializer(serializers.ModelSerializer):
    class Meta:
        model = LessonAsset
        fields = "__all__"
        read_only_fields = ["org","created_at","size_bytes","duration_seconds"]