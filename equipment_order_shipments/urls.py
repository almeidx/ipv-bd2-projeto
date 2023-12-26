from django.urls import path
from .views import index, info, register

urlpatterns = [
    path("", index, name="index"),
    path("<int:id>", info),
    path("<int:id>/register", register),
]
