from django.urls import path
from .views import index, edit, register, delete

urlpatterns = [
    path("", index, name="index"),
    path("edit/<str:id>", edit),
    path("register/", register),
    path("delete/<str:id>", delete),
]
