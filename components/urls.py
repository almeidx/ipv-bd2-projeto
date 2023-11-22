from django.contrib import admin
from django.urls import path
from .views import index, register, edit , list_stock, list_orders, register_order

urlpatterns = [
		path("", index, name="index"),
		path("register/", register),
		path("edit/", edit),
		path("list_stock/", list_stock),
		path("list_orders/", list_orders),
		path("register_order/", register_order)
]
