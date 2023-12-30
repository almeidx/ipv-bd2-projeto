from django.urls import path
from .views import index, register, edit, stock, delete, upload

urlpatterns = [
    path("", index, name="index"),
    path("register/", register),
    path("edit/<int:id>", edit),
    path("delete/<int:id>", delete),
    path("stock/", stock),
    path("upload/", upload),
]
