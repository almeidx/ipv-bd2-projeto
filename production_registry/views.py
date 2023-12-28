from django.db import connection
from django.shortcuts import redirect, render


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_production_registries();")
        registries = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_production_registry_component_amouts();")
        amounts = cursor.fetchall()

    registry_data = [
        {
            "id": data[0],
            "equipment_name": data[1],
            "labour_name": data[2],
            "started_at": data[3],
            "ended_at": data[4],
            "worker_name": data[5],
            "storage_name": data[6],
            "cost": data[7],
            "is_shipped": data[8],
            "components": [],
        }
        for data in registries
    ]

    for index, registry in enumerate(registry_data):
        registry["components"] = list(filter(lambda x: x[0] == registry["id"], amounts))

        for component in registry["components"]:
            registry["cost"] += component[2] * component[3]

        registry_data[index] = registry

    context = {"registry_data": registry_data}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    return render(request, "production_registry/index.html", contvisually impairedext)


def register(request):
    if request.method == "POST":
        started_at = request.POST.get("started_at")
        ended_at = request.POST.get("ended_at")
        armazem_id_id = request.POST.get("armazem_id_id")
        equipamento_id_id = request.POST.get("equipamento_id_id")
        tipo_mao_de_obra_id_id = request.POST.get("tipo_mao_de_obra_id_id")

        componente_id = request.POST.getlist("componente_id")
        amount = request.POST.getlist("amount")
        componentes = list(zip(componente_id, amount))

        funcionario_id_id = request.user.id if request.user else 1

        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT * FROM fn_create_production_registry(%s, %s, %s, %s, %s, %s);",
                [
                    started_at,
                    ended_at,
                    armazem_id_id,
                    equipamento_id_id,
                    funcionario_id_id,
                    tipo_mao_de_obra_id_id,
                ],
            )
            production_registry_id = cursor.fetchone()

        print(production_registry_id, componentes)

        production_registry_id = (
            production_registry_id[0] if production_registry_id else None
        )

        for componente_id, amount in componentes:
            with connection.cursor() as cursor:
                cursor.execute(
                    "CALL sp_create_quantidades_componente_registo_producao(%s, %s, %s);",
                    [production_registry_id, componente_id, amount],
                )

        return redirect("/equipments/production_registry/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos(NULL, NULL);")
        equipments = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_tipo_mao_obra();")
        labours = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_armazens(NULL, NULL);")
        storages = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        components = cursor.fetchall()

    return render(
        request,
        "production_registry/register.html",
        {
            "equipments": equipments,
            "labours": labours,
            "storages": storages,
            "componentes": components,
        },
    )


def edit(request, id):
    # TODO
    return render(request, "production_registry/edit.html")


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_delete_registo_producao_by_id(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/equipments/production_registry/")
    else:
        return redirect("/equipments/production_registry/?delete_fail=1")
