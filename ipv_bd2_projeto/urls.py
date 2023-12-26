from django.contrib import admin
from django.urls import path, include
from .views import index, login_view, logout_view

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", index, name="home"),
    path("login/", login_view),
    path("logout/", logout_view),
    path("components/", include("components.urls")),
    path("components/orders/", include("component_orders.urls")),
    path("users/", include("users.urls")),
    path("equipments/", include("equipments.urls")),
    path("equipments/orders/", include("equipment_orders.urls")),
    path("equipments/orders/shipments/", include("equipment_order_shipments.urls")),
    path("equipments/orders/invoices/", include("equipment_order_invoices.urls")),
    path("equipments/production_registry/", include("production_registry.urls")),
    path("labor/", include("labor.urls")),
    path("attributes/", include("attributes.urls")),
    path("suppliers/", include("suppliers.urls")),
    path("equipments/types/", include("equipment_type.urls")),
    path("storage/", include("storage.urls")),
]
