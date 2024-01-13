from django.shortcuts import render, redirect
from django.db import connection
from django.http import HttpResponse, JsonResponse
import xml.etree.ElementTree as ET


def index(request):
    filter_name = request.POST.get("filter_name") or ""
    sort_order = request.POST.get("sort_order")

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM fn_get_component_orders(%s,%s);",
            ["" if filter_name == "" else "%" + filter_name + "%", sort_order],
        )
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

    context = {"component_orders": component_orders}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    return render(request, "component_orders/index.html", context)


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


def edit(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_order_amounts();")
        amounts = cursor.fetchall()

    amounts = list(filter(lambda x: x[0] == id, amounts))

    if request.method == "POST":
        fornecedor_id_id = request.POST["fornecedor_id_id"]

        componente_id = request.POST.getlist("componente_id")
        amount = request.POST.getlist("amount")

        componentes = list(zip(componente_id, amount))

        funcionario_id_id = request.user.id if request.user else 1

        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_edit_encomenda_componentes(%s, %s, %s);",
                [id, fornecedor_id_id, funcionario_id_id],
            )

        for componente_id, amount in componentes:
            with connection.cursor() as cursor:
                cursor.execute(
                    "CALL sp_edit_quantidades_encomenda_componentes(%s, %s, %s);",
                    [id, componente_id, amount],
                )

        componente_id = [int(x) for x in componente_id]

        existing_amount_ids = [amount[4] for amount in amounts]
        submitted_amount_ids = [int(x) for x in request.POST.getlist("amount_id")]

        for amount_id in existing_amount_ids:
            if amount_id not in submitted_amount_ids:
                with connection.cursor() as cursor:
                    cursor.execute(
                        "CALL sp_delete_quantidade_encomenda_componente(%s);",
                        [amount_id],
                    )

        return redirect("/components/orders/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_encomenda_componentes_by_id(%s);", [id])
        component_order = cursor.fetchone()

    preset_component_amounts = []

    for amount in amounts:
        preset_component_amounts.append(
            {"component_id": amount[3], "amount": amount[2], "amount_id": amount[4]}
        )

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        componentes = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    return render(
        request,
        "component_orders/edit.html",
        {
            "components_order": component_order,
            "preset_component_amounts": preset_component_amounts,
            "componentes": componentes,
            "sellers": sellers,
        },
    )


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT public.fn_delete_encomenda_componente(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/components/orders/")
    else:
        return redirect("/components/orders/?delete_fail=true")


def fetch_data(query):
    with connection.cursor() as cursor:
        cursor.execute(query)
        return cursor.fetchall()


def export_xml(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_orders();")
        component_orders = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_order_amounts();")
        amounts = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("CALL sp_mark_component_orders_as_exported();")

    for index, component_order in enumerate(component_orders):
        amounts_for_order = list(filter(lambda x: x[0] == component_order[0], amounts))
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


def export_json(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_orders();")
        component_orders = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_order_amounts();")
        amounts = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("CALL sp_mark_component_orders_as_exported();")

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

    response = JsonResponse(serialized_data, safe=False)

    response["Content-Disposition"] = 'attachment; filename="exported_data.json"'
    response["Content-Type"] = "application/json"

    return response
