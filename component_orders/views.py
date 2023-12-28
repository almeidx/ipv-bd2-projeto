from django.shortcuts import render, redirect
from django.db import connection

from django.http import HttpResponse, JsonResponse
import xml.etree.ElementTree as ET

import json

from django.core.serializers.json import DjangoJSONEncoder


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_orders();")
        component_orders = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_order_amounts();")
        amounts = cursor.fetchall()

    context = {"component_orders": component_orders}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    for index, component_order in enumerate(component_orders):
        amounts_for_order = list(filter(lambda x: x[0] == component_order[0], amounts))
        tmp_list = list(component_order)
        tmp_list.append(amounts_for_order)

        component_orders[index] = tuple(tmp_list)

    return render(
        request, "component_orders/index.html", {"component_orders": component_orders}
    )


def register(request):
    if request.method == "POST":
        created_at = request.POST["created_at"]
        fornecedor_id_id = request.POST["fornecedor_id_id"]

        componente_id = request.POST.getlist("componente_id")
        amount = request.POST.getlist("amount")
        componentes = list(zip(componente_id, amount))

        funcionario_id_id = request.user.id if request.user else 1

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM fn_create_encomenda_componentes(%s, %s, %s);",
                [
                    created_at,
                    funcionario_id_id,
                    fornecedor_id_id,
                ],
            )
            encomenda_id = cursor.fetchone()

        print(encomenda_id, componentes)

        encomenda_id = encomenda_id[0] if encomenda_id else None

        for componente_id, amount in componentes:
            with connection.cursor() as cursor:
                cursor.execute(
                    "CALL sp_create_quantidades_encomenda_componentes(%s, %s, %s);",
                    [encomenda_id, componente_id, amount],
                )

        return redirect("/components/orders/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        componentes = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    return render(
        request,
        "component_orders/register.html",
        {"componentes": componentes, "sellers": sellers},
    )


def register_received(request):
    return render(request, "component_orders/register_received.html")


from django.http import HttpResponse


from django.http import JsonResponse


from django.http import JsonResponse


def edit(request, id):
    if request.method == "POST":
        try:
            # Retrieve form data
            componente_id = request.POST["componente"]
            fornecedor_id = request.POST["fornecedor"]
            quantidade = request.POST["new_quantidade"]

            new_item = "componente2"

            return JsonResponse({"success": True, "newItem": new_item})

        except ValueError as e:
            return JsonResponse({"success": False, "error": str(e)})

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_encomenda_componentes_by_id(%s);", [id])
        components_orders = cursor.fetchone()

    return render(
        request, "component_orders/edit.html", {"components_orders": components_orders}
    )


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT public.fn_delete_encomenda_componente(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/components/orders/")
    else:
        return redirect("/components/orders/?delete_fail")


def fetch_data(query):
    with connection.cursor() as cursor:
        cursor.execute(query)
        return cursor.fetchall()


def export_xml(request):
    try:
        component_orders = fetch_data("SELECT * FROM fn_get_component_orders();")
        amounts = fetch_data("SELECT * FROM fn_get_component_order_amounts();")

        for index, component_order in enumerate(component_orders):
            amounts_for_order = list(
                filter(lambda x: x[0] == component_order[0], amounts)
            )
            component_order += (amounts_for_order,)

            component_orders[index] = component_order

        root = ET.Element("data")

        for component_order in component_orders:
            order_elem = ET.SubElement(root, "component_order")
            ET.SubElement(order_elem, "id").text = str(component_order[0])
            ET.SubElement(order_elem, "data").text = str(component_order[1])
            components_elem = ET.SubElement(order_elem, "components")

            for component in component_order[5]:
                component_elem = ET.SubElement(components_elem, "component")
                ET.SubElement(component_elem, "name").text = str(component[1])
                ET.SubElement(component_elem, "quantity").text = str(component[2])

            ET.SubElement(order_elem, "supplier").text = str(component_order[2])
            ET.SubElement(order_elem, "exported").text = (
                "Sim" if component_order[4] else "Não"
            )

        xml_data = ET.tostring(root, encoding="utf-8", method="xml")
        response = HttpResponse(xml_data, content_type="application/xml")
        response["Content-Disposition"] = 'attachment; filename="exported_data.xml"'
        return response

    except Exception as e:
        return HttpResponse(f"An error occurred: {str(e)}", status=500)


def export_json(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_orders();")
        component_orders = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_order_amounts();")
        amounts = cursor.fetchall()

    amounts_dict = {}
    for amount in amounts:
        order_id = amount[0]
        if order_id not in amounts_dict:
            amounts_dict[order_id] = []
        amounts_dict[order_id].append(amount)

    serialized_data = []
    for component_order in component_orders:
        order_id = component_order[0]
        amounts_for_order = amounts_dict.get(order_id, [])

        serialized_data.append(
            {
                "id": component_order[0],
                "created at": component_order[1],
                "supplier": component_order[2],
                "employee": component_order[3],
                "components": [
                    {"id": c[0], "name": c[1], "quantity": c[2]}
                    for c in amounts_for_order
                ],
            }
        )

    json_data = json.dumps(serialized_data, cls=DjangoJSONEncoder, indent=2)

    response = JsonResponse(serialized_data, safe=False)

    response["Content-Disposition"] = 'attachment; filename="exported_data.json"'
    response["Content-Type"] = "application/json"

    return response
