from django.db import connection
from django.shortcuts import redirect, render


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
        invoice = cursor.fetchone()

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
