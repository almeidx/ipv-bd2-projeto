from django.shortcuts import render
from django.db import connection, transaction
from django.shortcuts import render
from django.shortcuts import redirect
from django.db import connection


def index(request):
    filter_name = request.POST.get("filter_name") or ""
    sort_order = request.POST.get("sort_order")
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM fn_get_armazens(%s,%s);",
            ["" if filter_name == "" else "%" + filter_name + "%", sort_order],
        )
        storages = cursor.fetchall()

    context = {"storages": storages}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True  # type: ignore

    return render(request, "storage/index.html", context)


def edit(request, id):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_edit_armazem(%s, %s, %s, %s, %s);",
                [
                    id,
                    request.POST["name"],
                    request.POST["address"],
                    request.POST["postal_code"],
                    request.POST["locality"],
                ],
            )

        return redirect("/storage/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_armazem_by_id(%s);", [id])
        storage = cursor.fetchone()

    return render(request, "storage/edit.html", {"storage": storage})


def register(request):
    if request.method == "POST":
        name = request.POST["name"]
        address = request.POST["address"]
        postal_code = request.POST["postal_code"]
        locality = request.POST["locality"]

        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_create_armazem(%s, %s, %s, %s);",
                [name, address, postal_code, locality],
            )
            cursor.close()

        return redirect("/storage/")

    return render(request, "storage/register.html")


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT public.fn_delete_armazem_by_id(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/storage/")
    else:
        return redirect("/storage/?delete_fail=1")
