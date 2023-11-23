from django.contrib import admin
from django.urls import path
from .views import index, edit, register, stock, production_regestry

urlpatterns = [
    path("", index),
    path("edit/<int:id>", edit),
    path("register/", register),
    path("stock/", stock),
    path("production_regestry/", production_regestry),
]
