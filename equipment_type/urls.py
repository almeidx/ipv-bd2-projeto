from django.urls import path
from .views import index, register,edit

urlpatterns = [
	path("", index),
	path("register/", register),
	path("edit/<int:id>", edit)
]
