from django.contrib import admin
from django.urls import path, include
from .views import index, login, create_account

urlpatterns = [
    path('admin/', admin.site.urls),
    path("", index, name="index"),
    path('login/', login),
    path('create_account/', create_account),
    path("components/", include("components.urls")),
    path("components/orders/", include("component_orders.urls")),
    path("users/", include("users.urls")),
    path("equipments/", include("equipments.urls")),
    path("equipments/orders/", include("equipment_orders.urls")),
    path("equipments/production_registry/", include("production_registry.urls")),
    path("labor/", include("labor.urls")),
    path("equipments/invoice/", include("invoice.urls")),
    path("attributes/", include("attributes.urls")),
]
