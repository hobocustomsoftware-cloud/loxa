from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views_crud, views_sessions, views_agora, social_views
from rest_framework.response import Response
from rest_framework.reverse import reverse
from collections import OrderedDict
from django.urls import NoReverseMatch

class MyRouter(DefaultRouter):
    class APIRootView(DefaultRouter.APIRootView):
        def get(self, request, *args, **kwargs):
            resp = super().get(request, *args, **kwargs)
            data = OrderedDict(resp.data)  # type: ignore

            # add non-router endpoints safely
            def safe_add(key, name):
                try:
                    data[key] = reverse(name, request=request)
                except NoReverseMatch:
                    pass  # skip if URL name not found

            safe_add('agora-token', 'agora-token')
            # SimpleJWT default names (if you use them)
            safe_add('jwt-token-obtain-pair', 'token_obtain_pair')
            safe_add('jwt-token-refresh', 'token_refresh')
            # Your Google social endpoints
            safe_add('google-auth-url', 'google-auth-url')
            safe_add('google-auth-exchange', 'google-auth-exchange')
            safe_add('phone-register', 'phone')
            safe_add('phone-login', 'phone')
            safe_add('courses-tree', 'course-tree')

            return Response(data)

# 👇 Use MyRouter (not DefaultRouter)
router = MyRouter()
router.register(r"sessions", views_sessions.LiveSessionViewSet, basename="session")
router.register(r"seats", views_sessions.SeatReservationViewSet, basename="seat")
router.register(r"attendance", views_sessions.AttendanceViewSet, basename="attendance")
router.register(r"courses", views_crud.CourseViewSet, basename="course")
router.register(r"modules", views_crud.ModuleViewSet, basename="module")
router.register(r"lessons", views_crud.LessonViewSet, basename="lesson")
router.register(r"assets", views_crud.LessonAssetViewSet, basename="asset")
router.register(r'agora', views_agora.AgoraViewSet, basename='agora')


urlpatterns = [
    path("", include(router.urls)),

    # non-router endpoints (APIView / function views)
    path("auth/google/url/", social_views.GoogleAuthUrlView.as_view(), name="google-auth-url"),
    path("auth/google/exchange/", social_views.GoogleExchangeView.as_view(), name="google-auth-exchange"),
    path("agora/token/", views_agora.AgoraTokenView.as_view(), name="agora-token"),
    path("auth/phone", include("authphone.urls")),

    path("courses/<int:pk>/tree/", views_crud.CourseTreeView.as_view(), name="course-tree")

    # If you use SimpleJWT defaults (uncomment if you have them wired)
    # path("auth/jwt/create/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    # path("auth/jwt/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
