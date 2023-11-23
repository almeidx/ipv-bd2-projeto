from django.contrib import admin
from django.urls import path
from .views import index, register, register_received, edit

urlpatterns = [
		path("", index, name="index"),
		path("register/", register),
		path("register_received/", register_received),
		path("edit/", edit),
]
