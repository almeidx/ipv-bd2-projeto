from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.hashers import make_password

from ipv_bd2_projeto.models import Utilizador


def index(request):
    filter_name = request.POST.get("filter_name") or ""
    sort_order = request.POST.get("sort_order")

    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM fn_get_utilizadores(%s,%s);",
            ["" if filter_name == "" else "%" + filter_name + "%", sort_order],
        )
        users = cursor.fetchall()

    return render(
        request,
        "users/index.html",
        {"users": users},
    )


def edit(request, id):
    if request.method == "POST":
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM fn_get_user(%s);", [id])
            user = cursor.fetchone()

        with connection.cursor() as cursor:
            cursor.execute(
                "CALL sp_edit_user(%s, %s, %s, %s);",
                [
                    id,
                    request.POST["first_name"],
                    request.POST["last_name"],
                    request.POST["type"],
                ],
            )

        return redirect("/users/")

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_user(%s);", [id])
        user = cursor.fetchone()

    return render(request, "users/edit.html", {"user": user})


def register(request):
    if request.method == "POST":
        Utilizador.objects.create(
            first_name=request.POST["first_name"],
            last_name=request.POST["last_name"],
            email=request.POST["email"],
            password=make_password(request.POST["password"]),
            type=request.POST["type"],
            is_staff=(request.POST["type"] == "Administrador"),
            is_superuser=(request.POST["type"] == "Administrador"),
        )

        return redirect("/users/")

    return render(request, "users/register.html")
