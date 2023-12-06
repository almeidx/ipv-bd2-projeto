from django.urls import path
from .views import index, register, edit

urlpatterns = [
		path("", index, name="index"),
		path("register/", register),
		path("edit/", edit),
]
