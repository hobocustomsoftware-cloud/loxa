# api/auth_views.py
from rest_framework_simplejwt.views import TokenObtainPairView
from .auth_serializers import LoxaTokenObtainPairSerializer

class LoxaTokenView(TokenObtainPairView):
    serializer_class = LoxaTokenObtainPairSerializer
