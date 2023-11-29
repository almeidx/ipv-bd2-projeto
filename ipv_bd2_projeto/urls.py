from django.contrib import admin
from django.urls import path, include
from .views import index, login_view, create_account

urlpatterns = [
    path('admin/', admin.site.urls),
    path("", index, name="home"),
    path('login/', login_view),
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
	path("seller/", include("seller.urls")),
	path("equipments/types/", include("equipment_type.urls")),
	path("storage/", include("storage.urls")),
]
