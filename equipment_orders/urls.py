from django.urls import path
from .views import index, register, delete

urlpatterns = [
    path("", index, name="index"),
    path("register/", register),
    path("delete/<int:id>", delete),
]
