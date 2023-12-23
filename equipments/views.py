from django.conf import settings
from django.shortcuts import render, redirect
from django.db import connection
from pymongo import MongoClient
from bson.objectid import ObjectId


db_settings = settings.DATABASES["mongo"]
client = MongoClient(
    host=db_settings["CLIENT"]["host"],
    port=db_settings["CLIENT"]["port"],
    username=db_settings["CLIENT"]["username"],
    password=db_settings["CLIENT"]["password"],
    authSource=db_settings["AUTH_DATABASE"],
)
db = client[db_settings["NAME"]]
mongo_attributes = db["attributes"]
mongo_equipment_attributes = db["equipment_attributes"]
mongo_attribute_values = db["attribute_values"]


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos();")
        equipments = cursor.fetchall()

    context = {
        "equipments": [
            {
                "id": equipment[0],
                "name": equipment[1],
                "created_at": equipment[2],
                "equipment_type_name": equipment[3],
                "attributes": {},
            }
            for equipment in equipments
        ],
    }

    for equipment in context["equipments"]:
        equipment_id = equipment["id"]

        equipment_attributes = mongo_equipment_attributes.find(
            {"equipmentId": "__pgs" + str(equipment_id)}
        )

        if equipment_attributes is None:
            continue

        for attribute in equipment_attributes:
            attribute_id = attribute["attributeId"]
            value_id = attribute["valueId"]

            attribute_name = mongo_attributes.find_one({"_id": ObjectId(attribute_id)})
            attribute_value = mongo_attribute_values.find_one(
                {"_id": ObjectId(value_id)}
            )

            if attribute_name is not None and attribute_value is not None:
                equipment["attributes"][attribute_name["name"]] = attribute_value[
                    "value"
                ]

    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    return render(request, "equipments/index.html", context)


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT fn_delete_equipment_by_id(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/equipments/")
    else:
        return redirect("/equipments/?delete_fail=1")


def register(request):
    attributes = [attribute for attribute in mongo_attributes.find()]
    values = mongo_attribute_values.find()

    attribute_values = []

    for attribute_value in values:
        attribute = None
        for attr in attributes:
            if attr["_id"] == attribute_value["attributeId"]:
                attribute = attr
                break

        if attribute is not None:
            attribute_values.append(
                {
                    "id": attribute["_id"],
                    "name": attribute["name"],
                    "value_id": attribute_value["_id"],
                    "value": attribute_value["value"],
                }
            )

    if request.method == "POST":
        name = request.POST["name"]
        tipo_equipment_id_id = request.POST["tipo_equipment_id_id"]
        attributes = request.POST.getlist("attributes")

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM fn_create_equipment(%s, %s);",
                [name, tipo_equipment_id_id],
            )
            equipment_id = cursor.fetchone()[0]  # type: ignore

        for attribute in attributes:
            attribute_id, value_id = attribute.split(":")

            mongo_equipment_attributes.insert_one(
                {
                    "equipmentId": "__pgs" + str(equipment_id),
                    "attributeId": ObjectId(attribute_id),
                    "valueId": ObjectId(value_id),
                }
            )

        return redirect("/equipments/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_tipo_equipamentos();")
        equipment_types = cursor.fetchall()

    context = {"attributes": attribute_values, "equipment_types": equipment_types}
    return render(request, "equipments/register.html", context)


def edit(request, id):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_edit_tipo_equipamento(%s, %s);",
                [id, request.POST["name"], request.POST["tipo_equipment_id_id"]],
            )

        return redirect("/equipments/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamento_by_id(%s);", [id])
        equipment = cursor.fetchone()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_tipo_equipamentos();")
        equipment_types = cursor.fetchall()

    return render(
        request,
        "equipments/edit.html",
        {"equipment_types": equipment_types, "equipment": equipment},
    )


def stock(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos();")
        equipments = cursor.fetchall()

    return render(request, "equipments/stock.html", {"equipments": equipments})
