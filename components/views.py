from django.shortcuts import render, redirect
from django.db import connection


def index(request):
    filter_name = request.POST.get("filter_name") or ""
    sort_order = request.POST.get("sort_order")

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM  fn_get_components(%s, %s);",
            ["" if filter_name == "" else "%" + filter_name + "%", sort_order],
        )
        components = cursor.fetchall()

    context = {"components": components}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    print(components)

    return render(request, "components/index.html", context)


def register(request):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_create_component(%s, %s, %s);",
                [
                    request.POST["name"],
                    request.POST["cost"],
                    request.POST["fornecedor_id_id"],
                ],
            )
            cursor.close()

        return redirect("/components/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    return render(request, "components/register.html", {"sellers": sellers})


def edit(request, id):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_edit_component(%s, %s, %s, %s);",
                [
                    id,
                    request.POST["name"],
                    request.POST["cost"],
                    request.POST["fornecedor_id_id"],
                ],
            )

        return redirect("/components/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_component(%s);", [id])
        component = cursor.fetchone()

    return render(
        request, "components/edit.html", {"component": component, "sellers": sellers}
    )


def stock(request):
    return render(request, "components/stock.html")


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT public.fn_delete_component_by_id(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/components/")
    else:
        return redirect("/components/?delete_fail=1")
