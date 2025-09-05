from rest_framework.permissions import BasePermission
from .models import OrgMembership

class IsOrgMember(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and getattr(request, "org", None) is not None
            and OrgMembership.objects.filter(org=request.org, user=request.user).exists()
        )