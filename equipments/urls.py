from django.urls import path
from .views import index, edit, register, stock, delete

urlpatterns = [
    path("", index),
    path("edit/<int:id>", edit),
    path("register/", register),
    path("stock/", stock),
    path("delete/<int:id>", delete)
]
