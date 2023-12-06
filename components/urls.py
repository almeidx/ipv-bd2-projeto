from django.urls import path
from .views import index, register, edit, stock

urlpatterns = [
		path("", index, name="index"),
		path("register/", register),
		path("edit/<int:id>", edit),
		path("stock/", stock)
]
