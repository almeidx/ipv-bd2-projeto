from django.urls import path
from .views import index, edit, register

urlpatterns = [
    path("", index, name="index"),
    path("edit/<int:id>", edit),
    path("register/", register),
]
