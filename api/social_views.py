# api/social_views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from social_django.utils import load_strategy, load_backend
from django.contrib.auth import login
from rest_framework_simplejwt.tokens import RefreshToken

class SocialAuthExchangeView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        provider = request.data.get("provider")   # "google-oauth2"
        access_token = request.data.get("access_token")
        if not provider or not access_token:
            return Response({"detail":"provider/access_token required"}, status=400)

        strategy = load_strategy(request)
        backend = load_backend(strategy=strategy, name=provider, redirect_uri=None)
        user = backend.do_auth(access_token)
        if not user or not user.is_active:
            return Response({"detail":"invalid social token"}, status=400)

        login(request, user)  # optional
        refresh = RefreshToken.for_user(user)
        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh),
        })
