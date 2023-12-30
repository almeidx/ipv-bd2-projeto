from django.db import connection
from django.shortcuts import redirect, render


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_guia_entrega_componentes();")
        received = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_guia_entrega_componentes_amounts();")
        amounts = cursor.fetchall()

    for index, guia_entrega in enumerate(received):
        amounts_for_order = list(filter(lambda x: x[0] == guia_entrega[0], amounts))
        tmp_list = list(guia_entrega)
        tmp_list.append(amounts_for_order)

        received[index] = tuple(tmp_list)

    return render(
        request, "component_order_received/index.html", {"received": received}
    )


def register(request):
    if request.method == "POST":
        armazem_id_id = request.POST["armazem_id_id"]
        created_at = request.POST["created_at"]

        componente_id = request.POST.getlist("componente_id")
        amount = request.POST.getlist("amount")

        componentes = list(zip(componente_id, amount))

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM fn_create_guia_entrega_componentes(%s, %s);",
                [
                    created_at,
                    armazem_id_id,
                ],
            )
            guia_entrega_id = cursor.fetchone()

        guia_entrega_id = guia_entrega_id[0] if guia_entrega_id else None

        for componente_id, amount in componentes:
            with connection.cursor() as cursor:
                cursor.execute(
                    "CALL sp_create_quantidades_guia_entrega_componentes(%s, %s, %s);",
                    [guia_entrega_id, componente_id, amount],
                )

        return redirect("/components/orders/received/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_armazens(NULL, NULL);")
        storages = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        components = cursor.fetchall()

    return render(
        request,
        "component_order_received/register.html",
        {"storages": storages, "components": components},
    )
