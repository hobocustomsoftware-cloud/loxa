# api/urls.py
from django.urls import path
from rest_framework.routers import DefaultRouter

# ✅ IMPORTS: names must match exactly to the classes defined in views_sessions.py
from api.views_sessions import (
    LiveSessionViewSet,
    SeatReservationViewSet,
    AttendanceViewSet,
)
# (အကယ်၍ academics ကိုပါ expose မယ်ဆိုရင်)
from .views_crud import (
    CourseViewSet, ModuleViewSet, LessonViewSet, LessonAssetViewSet
)

from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

router = DefaultRouter()
router.register(r"sessions", LiveSessionViewSet, basename="session")
router.register(r"seats",    SeatReservationViewSet, basename="seat")
router.register(r"attendance", AttendanceViewSet, basename="attendance")

# academics
router.register(r"courses", CourseViewSet, basename="course")
router.register(r"modules", ModuleViewSet, basename="module")
router.register(r"lessons", LessonViewSet, basename="lesson")
router.register(r"assets",  LessonAssetViewSet, basename="asset")

urlpatterns = [
    # path("", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    # path("refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    # path("verify/", TokenVerifyView.as_view(), name="token_verify"),
] + router.urls
