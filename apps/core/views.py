from django.apps import apps
from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render


@login_required
def dashboard_view(request):
    if getattr(request.user, "is_staff", False) and request.GET.get("skip_wizard") != "1" and apps.is_installed("seed_kit"):
        try:
            from seed_kit.models import SetupWizardState
            state = SetupWizardState.get_solo()
            if not state.is_completed and not state.hide_on_start:
                return redirect("seed_kit:wizard")
        except Exception:
            pass
    if not getattr(request.user, "is_staff", False) and apps.is_installed("domain_kit"):
        try:
            from domain_kit.services import has_any_domain_access
            if not has_any_domain_access(request.user):
                return redirect("domain_kit:self_service")
        except Exception:
            pass
    return render(request, "dashboard.html")
