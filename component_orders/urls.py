from django.urls import path
from .views import (
    index,
    register,
    register_received,
    edit,
    export_xml,
    export_json,
    delete_encomenda,
)

urlpatterns = [
    path("", index, name="index"),
    path("register/", register),
    path("register_received/", register_received),
    path("edit/<int:id>", edit),
    path("export-xml/", export_xml, name="export_xml"),
    path("export-json/", export_json, name="export_json"),
    path("delete/<int:id>", delete_encomenda),
]
