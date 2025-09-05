# api/views_crud.py
from api.serializers_academics import LessonAssetSerializer
from rest_framework import viewsets, permissions
from orgs.permissions import IsOrgMember
from .models_academics import Course, Module, Lesson, LessonAsset
from .serializers import CourseSer, ModuleSer, LessonSer, AssetSer


class OrgScopedMixin:
    model = None
    def get_queryset(self):
        return self.model.objects.filter(org=self.request.org) # type: ignore
    def perform_create(self, serializer):
        serializer.save(org=self.request.org) # type: ignore


class CourseViewSet(OrgScopedMixin, viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsOrgMember]
    serializer_class = CourseSer
    model = Course


class ModuleViewSet(OrgScopedMixin, viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated, IsOrgMember]
    serializer_class = ModuleSer
    model = Module


class LessonViewSet(OrgScopedMixin, viewsets.ModelViewSet):   # ← missing one
    permission_classes = [permissions.IsAuthenticated, IsOrgMember]
    serializer_class = LessonSer
    model = Lesson


class LessonAssetViewSet(viewsets.ModelViewSet):
    queryset = LessonAsset.objects.all()
    serializer_class = LessonAssetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        file_obj = self.request.FILES.get("file")
        obj = serializer.save(org=self.request.org)
        size = file_obj.size if file_obj else 0
        serializer.save(org=self.request.org, size_bytes=size)

        return obj



