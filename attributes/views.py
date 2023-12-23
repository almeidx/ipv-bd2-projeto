from bson import ObjectId
from django.shortcuts import render
from django.http import HttpResponse
from django.conf import settings
from pymongo import MongoClient
from django.shortcuts import redirect


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
    attributes = mongo_attributes.find()
    values = mongo_attribute_values.find()

    clone = [
        {
            "id": attribute["_id"],
            "name": attribute["name"],
            "values": [],
        }
        for attribute in attributes
    ]

    for value in values:
        for attribute in clone:
            if attribute["id"] == value["attributeId"]:
                attribute["values"].append(value["value"])

    context = {"attributes": clone}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    return render(request, "attributes/index.html", context)


def edit(request, id):
    attribute = mongo_attributes.find_one({"_id": ObjectId(id)})
    values = [
        {
            "id": value["_id"],
            "value": value["value"],
        }
        for value in mongo_attribute_values.find({"attributeId": ObjectId(id)})
    ]

    if request.method == "POST":
        name = request.POST.get("name")

        values_data = []
        for key in request.POST:
            if key.startswith("value:"):
                value_id = key.split(":")[1]
                value_id = None if value_id.isnumeric() else ObjectId(value_id)

                values_data.append(
                    {
                        "id": value_id,
                        "value": request.POST[key],
                    }
                )

        mongo_attributes.update_one({"_id": ObjectId(id)}, {"$set": {"name": name}})

        value_ids = [value["id"] for value in values_data]
        deleted_ids = set()
        for value in values:
            if value["id"] not in value_ids:  # valor removido
                is_used_elsewhere = mongo_equipment_attributes.find_one(
                    {"valueId": value["id"]}
                )
                if is_used_elsewhere:
                    return redirect("/attributes?delete_fail=true")

                mongo_attribute_values.delete_one({"_id": value["id"]})
                deleted_ids.add(value["id"])

        for value in values_data:
            if value["id"] is None:  # valor novo
                mongo_attribute_values.insert_one(
                    {"attributeId": ObjectId(id), "value": value["value"]}
                )
            elif value["id"] not in deleted_ids:  # valor atualizado
                mongo_attribute_values.update_one(
                    {"_id": value["id"]},
                    {"$set": {"value": value["value"]}},
                )

        return redirect("/attributes")

    return render(
        request, "attributes/edit.html", {"attribute": attribute, "values": values}
    )


def register(request):
    if request.method == "POST":
        name = request.POST.get("name")
        values = request.POST.getlist("values")

        attribute = mongo_attributes.insert_one({"name": name})
        mongo_attribute_values.insert_many(
            [
                {"attributeId": ObjectId(attribute.inserted_id), "value": value.strip()}
                for value in values
                if value.strip() != ""
            ]
        )

        return redirect("/attributes")

    return render(request, "attributes/register.html")


def delete(request, id):
    is_used_elsewhere = mongo_equipment_attributes.find_one(
        {"attributeId": ObjectId(id)}
    )

    if is_used_elsewhere:
        return redirect("/attributes?delete_fail=true")

    mongo_attributes.delete_one({"_id": ObjectId(id)})
    mongo_attribute_values.delete_many({"attributeId": ObjectId(id)})

    return redirect("/attributes")
