from django.db import connection
from django.shortcuts import render, redirect


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipment_orders();")
        equipment_orders = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipment_order_amounts();")
        amounts = cursor.fetchall()

    context = {"equipment_orders": equipment_orders}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    for index, equipment_order in enumerate(equipment_orders):
        amounts_for_order = list(filter(lambda x: x[0] == equipment_order[0], amounts))
        tmp_list = list(equipment_order)
        tmp_list.append(amounts_for_order)

        equipment_orders[index] = tuple(tmp_list)

    return render(
        request, "equipment_orders/index.html", {"equipment_orders": equipment_orders}
    )


def register(request):
    if request.method == "POST":
        created_at = request.POST["created_at"]
        address = request.POST["address"]
        postal_code = request.POST["postal_code"]
        locality = request.POST["locality"]
        funcionario_id_id = request.user.id if request.user else 1
        client_id_id = request.POST["client_id_id"]

        equipment_id = request.POST.getlist("equipment_id")
        amount = request.POST.getlist("amount")
        equipamentos = list(zip(equipment_id, amount))

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM fn_create_encomenda_equipamento(%s, %s, %s, %s, %s, %s);",
                [
                    created_at,
                    address,
                    postal_code,
                    locality,
                    funcionario_id_id,
                    client_id_id,
                ],
            )
            encomenda_id = cursor.fetchone()

        encomenda_id = encomenda_id[0] if encomenda_id else None

        for equipment_id, amount in equipamentos:
            with connection.cursor() as cursor:
                cursor.execute(
                    "CALL sp_create_quantidades_encomenda_equipamentos(%s, %s, %s);",
                    [encomenda_id, equipment_id, amount],
                )

        return redirect("/equipments/orders/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_clients();")
        clients = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos();")
        equipments = cursor.fetchall()

    return render(
        request,
        "equipment_orders/register.html",
        {"clients": clients, "equipments": equipments},
    )


def edit(request):
    return render(request, "equipment_orders/edit.html")
