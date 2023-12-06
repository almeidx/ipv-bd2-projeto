from django.shortcuts import render, redirect
from django.db import connection

def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component_orders();")
        component_orders = cursor.fetchall()

    return render(request, "component_orders/index.html", {"component_orders": component_orders})


def register(request):
    if request.method == "POST":
        created_at = request.POST["created_at"]
        fornecedor_id_id = request.POST["fornecedor_id_id"]

        componente_id = request.POST.getlist("componente_id_id")
        amount = request.POST.getlist("amount")
        componentes = list(zip(componente_id, amount))

        funcionario_id_id = request.user.id if request.user else 1

        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM fn_create_encomenda_componentes(%s, %s, %s);", [
                created_at,
                funcionario_id_id,
                fornecedor_id_id,
            ])
            encomenda_id = cursor.fetchone()

        for (componente_id, amount) in componentes:
            with connection.cursor() as cursor:
                cursor.execute("CALL sp_create_quantidades_encomenda_componentes(%s, %s, %s);", [
                    encomenda_id,
                    componente_id,
                    amount
                ])

        return redirect("/componentes/orders/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        componentes = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    return render(request, "component_orders/register.html", {"componentes": componentes, "sellers": sellers})


def register_received(request):
	return render(request, "component_orders/register_received.html")


def edit(request, id):
    return render(request, "component_orders/edit.html")
    # if request.method == "POST":
    #     with connection.cursor() as cursor:
    #         cursor.execute("CALL sp_edit_encomenda_componentes(%s, %s, %s, %s, %s);", [
    #             id,
    #             request.POST['fornecedor_id'],
    #             request.POST['funcionario_responsavel_id'],
    #             request.POST['export']
    #             request.POST['amount']
    #         ])

    #     return redirect("/components/orders/")

    # with connection.cursor() as cursor:
    #     cursor.execute("SELECT * FROM fn_get_encomenda_componentes_by_id(%s);", [id])
    #     components_orders = cursor.fetchone()

    # return render(request, "components_orders/edit.html", {'components_orders': components_orders})
