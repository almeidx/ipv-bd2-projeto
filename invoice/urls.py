from django.contrib import admin
from django.urls import path
from .views import index, info, shipping

urlpatterns = [
    path("", index, name="index"),
    path("<int:id>", info),
    path("shipping/", shipping)
]
