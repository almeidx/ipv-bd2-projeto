from django.contrib import admin
from django.urls import path
from .views import index, info, shipping, create, info_expedicao

urlpatterns = [
    path("", index, name="index"),
    path("<int:id>", info),
    path("shipping/", shipping),
	path("create/",create ),
	path("info_expedicao/",info_expedicao ),

]
