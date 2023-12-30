from django.urls import path
from .views import (
    index,
    register,
    edit,
    export_xml,
    export_json,
    delete,
)

urlpatterns = [
    path("", index, name="index"),
    path("register/", register),
    path("edit/<int:id>", edit, name="edit"),
    path("export-xml/", export_xml, name="export_xml"),
    path("export-json/", export_json, name="export_json"),
    path("delete/<int:id>/", delete, name="delete"),
]
