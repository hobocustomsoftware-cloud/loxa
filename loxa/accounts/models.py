# accounts/models.py
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import (
    AbstractBaseUser, PermissionsMixin, BaseUserManager
)

from datetime import timedelta
from django.conf import settings


class UserManager(BaseUserManager):
    use_in_migrations = True

    def normalize_email(self, email):
        return super().normalize_email(email) if email else email

    def create_user(self, email, password=None, **extra):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra):
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        extra.setdefault("is_active", True)
        if not password:
            raise ValueError("Superuser must have a password")
        return self.create_user(email, password, **extra)

    # >>> ဒီဟာက admin/login အတွက်ဆိုဒ်တကျ အရေးကြီး <<<
    def get_by_natural_key(self, username):
        # USERNAME_FIELD = "email" ဖြစ်တဲ့အတွက် email နဲ့ရှာမယ်
        return self.get(**{self.model.USERNAME_FIELD: username})


class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=32, unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=150, blank=True)
    last_name  = models.CharField(max_length=150, blank=True)

    # Django admin & permissions တွေအတွက် လိုတယ်
    is_active = models.BooleanField(default=True)
    is_staff  = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS: list[str] = []   # createsuperuser 时要求的额外字段 (မလိုရင် ဗလာ)

    def __str__(self):
        return self.email or f"User#{self.pk}"




# class PhoneOTP(models.Model):
#     phone_number = models.CharField(max_length=32, db_index=True)
#     code = models.CharField(max_length=6)
#     created_at = models.DateTimeField(auto_now_add=True)

#     def is_valid(self):
#         return self.created_at >= timezone.now() - timedelta(minutes=5)