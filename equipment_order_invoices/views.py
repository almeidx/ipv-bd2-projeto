from django.conf import settings
from django.db import connection
from django.shortcuts import redirect, render
from pymongo import MongoClient

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
        cursor.execute("SELECT * FROM fn_get_equipment_order_invoices();")
        invoices = cursor.fetchall()

    return render(
        request, "equipment_order_invoices/index.html", {"invoices": invoices}
    )


def info(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipment_order_invoice_by_id(%s);", [id])
        invoice = cursor.fetchone()[0]  # type: ignore

    for registo in invoice["expedicao"]["registos_producao"]:
        registo["price"] = registo["tipo_mao_de_obra_cost"] + sum(
            componente["component_cost"] * componente["amount"]
            for componente in registo["componentes_usados"]
        )

        equipment_attributes = [
            x
            for x in mongo_equipment_attributes.find(
                {"equipmentId": "__pgs" + str(registo["equipamento_id"])}
            )
        ]

        registo["atributos"] = []

        for attribute in equipment_attributes:
            attr_name = mongo_attributes.find_one({"_id": attribute["attributeId"]})
            attr_value = mongo_attribute_values.find_one({"_id": attribute["valueId"]})

            registo["atributos"].append(
                {
                    "name": attr_name["name"],  # type: ignore
                    "value": attr_value["value"],  # type: ignore
                }
            )

    return render(request, "equipment_order_invoices/info.html", {"invoice": invoice})


def register(request, id):
    if request.method == "POST":
        created_at = request.POST["created_at"]
        contribuinte = request.POST["contribuinte"]

        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_create_fatura(%s, %s, %s);",
                [
                    created_at,
                    contribuinte,
                    id,
                ],
            )

        return redirect("/equipments/orders/invoices")

    return render(request, "equipment_order_invoices/register.html")
