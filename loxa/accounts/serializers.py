from rest_framework import serializers
# from django.contrib.auth import get_user_model
from .models import  User
from django.utils.crypto import get_random_string

# User = get_user_model()

class PhoneRegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "phone_number", "password"]
        extra_kwargs = {"password": {"write_only": True}}

    def create(self, validated_data):
        user = User.objects.create_user( # type: ignore
            phone_number=validated_data["phone_number"],
            password=validated_data["password"],
        ) # type: ignore
        return user


class PhoneLoginSerializer(serializers.Serializer):
    phone_number = serializers.CharField()
    password = serializers.CharField(write_only=True)




# class RequestOTPSerializer(serializers.Serializer):
#     phone_number = serializers.CharField()

#     def create(self, validated_data):
#         phone = validated_data["phone_number"]
#         # generate 6 digit
#         code = get_random_string(6, allowed_chars="0123456789")
#         PhoneOTP.objects.create(phone_number=phone, code=code)
#         # TODO: integrate SMS provider here (e.g., Twilio, local SMS gateway)
#         print(f"DEBUG OTP for {phone} = {code}")  # console for dev
#         return {"phone_number": phone}


# class VerifyOTPSerializer(serializers.Serializer):
#     phone_number = serializers.CharField()
#     code = serializers.CharField(max_length=6)

#     def validate(self, attrs):
#         phone = attrs["phone_number"]
#         code = attrs["code"]
#         try:
#             otp = PhoneOTP.objects.filter(phone_number=phone).latest("created_at")
#         except PhoneOTP.DoesNotExist:
#             raise serializers.ValidationError("OTP not requested")

#         if not otp.is_valid():
#             raise serializers.ValidationError("OTP expired")
#         if otp.code != code:
#             raise serializers.ValidationError("Invalid code")
#         attrs["otp"] = otp
#         return attrs

#     def create(self, validated_data):
#         phone = validated_data["phone_number"]

#         user, _ = User.objects.get_or_create(
#             phone_number=phone,
#             defaults={"email": f"{phone}@autogen.local", "is_active": True}
#         )

#         from rest_framework_simplejwt.tokens import RefreshToken
#         refresh = RefreshToken.for_user(user)
#         return {
#             "refresh": str(refresh),
#             "access": str(refresh.access_token),
#             "user_id": user.id, # type: ignore
#             "phone_number": user.phone_number
#         }