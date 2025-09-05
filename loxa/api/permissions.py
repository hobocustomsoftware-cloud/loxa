# api/permissions.py
from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsSessionModeratorOrOwner(BasePermission):
    def has_object_permission(self, request, view, obj):
        if getattr(obj, "owner_id", None) == request.user.id:
            return True
        # TODO: implement is_moderator check (OrgRole, Program staff, Course teacher etc.)
        return getattr(request.user, "is_staff", False)
