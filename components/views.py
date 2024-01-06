import json
from django.http import HttpResponse, HttpResponseBadRequest
from django.shortcuts import render, redirect
from django.db import connection
from .forms import ComponenteForm


def index(request):
    filter_name = request.POST.get("filter_name") or ""
    sort_order = request.POST.get("sort_order")

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM  fn_get_components(%s, %s);",
            ["" if filter_name == "" else "%" + filter_name + "%", sort_order],
        )
        components = cursor.fetchall()

    context = {"components": components, "form": ComponenteForm()}
    if request.GET.get("delete_fail"):
        context["delete_fail"] = True

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
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_stock_componentes();")
        stock_componentes = cursor.fetchall()

    return render(
        request, "components/stock.html", {"stock_componentes": stock_componentes}
    )


def delete(request, id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT public.fn_delete_component_by_id(%s);", [id])
        result = cursor.fetchone()
        deleted_successfully = result[0] if result is not None else False

    if deleted_successfully:
        return redirect("/components/")
    else:
        return redirect("/components/?delete_fail=1")


def upload(request):
    if request.method == "POST":
        form = ComponenteForm(request.POST, request.FILES)

        if form.is_valid():
            uploaded_file = request.FILES["file"]

            try:
                content = uploaded_file.read().decode("utf-8")
                data = json.loads(content)

                if is_valid_data(data):
                    with connection.cursor() as cursor:
                        cursor.callproc("fn_import_components", [json.dumps(data)])
                else:
                    return HttpResponseBadRequest("Error: Invalid data format.")
            except json.JSONDecodeError:
                return HttpResponse("Error: Invalid JSON file.")

    return redirect("/components/")


def is_valid_data(data):
    if not isinstance(data, list):
        return False

    for item in data:
        if (
            not isinstance(item, dict)
            or "name" not in item
            or "cost" not in item
            or "supplier" not in item
        ):
            return False

        supplier = item["supplier"]
        if (
            not isinstance(supplier, dict)
            or "name" not in supplier
            or "email" not in supplier
            or "address" not in supplier
            or "postal_code" not in supplier
            or "locality" not in supplier
        ):
            return False

    return True
