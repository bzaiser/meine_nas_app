from django.conf import settings
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve

from apps.core.views import dashboard_view

urlpatterns = [
    path("admin/", admin.site.urls),
    path("design-studio/", include("design_studio.urls")),
    path("ops/", include("ops_kit.urls")),
    re_path(r"^media/(?P<path>.*)$", serve, {"document_root": settings.MEDIA_ROOT}),
    path("app/", dashboard_view, name="home" if "site_kit" in settings.INSTALLED_APPS else "app_home"),
]

try:
    from ops_kit.runtime import get_runtime_urlpatterns, optional_kit_path
    urlpatterns += optional_kit_path("domain_kit", "domain/", "domain_kit.urls")
    urlpatterns += optional_kit_path("auth_kit", "accounts/", "auth_kit.urls")
    urlpatterns += optional_kit_path("notify_kit", "notifications/", "notify_kit.urls")
    urlpatterns += optional_kit_path("cal_kit", "calendar/", "cal_kit.urls")
    urlpatterns += get_runtime_urlpatterns(settings.BASE_DIR, urlpatterns)
except ImportError:
    urlpatterns += [
        path("domain/", include("domain_kit.urls")),
        path("accounts/", include("auth_kit.urls")),
        path("notifications/", include("notify_kit.urls")),
        path("calendar/", include("cal_kit.urls")),
    ]

if "site_kit" not in settings.INSTALLED_APPS:
    urlpatterns += [
        path("", dashboard_view, name="home"),
    ]
