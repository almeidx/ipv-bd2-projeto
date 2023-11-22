from django.contrib import admin
from django.urls import path, include
from .views import index, login, create_account

urlpatterns = [
    path('admin/', admin.site.urls),
    path("", index, name="index"),
    path('login/', login),
    path('create_account/', create_account),
    path("components/", include("components.urls")),
    path("clients/", include("clients.urls")),
]
