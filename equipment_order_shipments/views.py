from django.db import connection
from django.shortcuts import redirect, render


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_expedicao();")
        shipments = cursor.fetchall()

    print(shipments)

    return render(
        request, "equipment_order_shipments/index.html", {"shipments": shipments}
    )


def info(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_expedicao_by_id(%s);", [id])
        shipment = cursor.fetchone()[0]  # type: ignore

    total_cost = sum(
        map(
            lambda registo: registo["tipo_mao_de_obra_cost"]
            + sum(
                map(
                    lambda componente: componente["component_cost"]
                    * componente["amount"],
                    registo["componentes_usados"],
                )
            ),
            shipment["registos_producao"],
        )
    )

    print(shipment, total_cost)

    return render(
        request,
        "equipment_order_shipments/info.html",
        {"shipment": shipment, "total_cost": total_cost},
    )


def register(request, id):
    if request.method == "POST":
        sent_at = request.POST["sent_at"]
        truck_license = request.POST["truck_license"]
        delivery_date_expected = request.POST["delivery_date_expected"]
        production_registry_id_id = request.POST.getlist("production_registry_id_id")

        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_create_expedicao(%s, %s, %s, %s, %s);",
                [
                    sent_at,
                    truck_license,
                    delivery_date_expected,
                    id,
                    list(map(int, production_registry_id_id)),
                ],
            )

        return redirect("/equipments/orders/shipments")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_unassigned_production_registries();")
        production_registries = cursor.fetchall()

    return render(
        request,
        "equipment_order_shipments/register.html",
        {"production_registries": production_registries},
    )
