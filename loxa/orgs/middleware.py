from .models import Org

def current_org_middleware(get_response):
    def middleware(request):
        org_id = request.headers.get("X-Org-ID")
        request.org = None
        if org_id:
            try:
                request.org = Org.objects.get(id=org_id)
            except Org.DoesNotExist:
                request.org = None
        return get_response(request)
    return middleware