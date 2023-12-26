from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.hashers import make_password

from ipv_bd2_projeto.models import Utilizador


def index(request):
    search_query = request.GET.get("search", "")
    order_by = request.GET.get("order_by", "id") if "order_by" in request.GET else None

    if search_query or order_by:
        with connection.cursor() as cursor:
            if search_query:
                if search_query.isdigit():
                    cursor.execute("SELECT * FROM fn_get_user(%s);", [search_query])
                else:
                    if " " in search_query:
                        first_name, last_name = search_query.split(" ", 1)
                        cursor.execute(
                            "SELECT * FROM fn_get_user_name(%s, %s);",
                            [first_name, last_name],
                        )
                    else:
                        cursor.execute(
                            "SELECT * FROM fn_get_user_name(%s, NULL) UNION SELECT * FROM fn_get_user_name(NULL, %s);",
                            [search_query],
                        )
            else:
                cursor.execute("SELECT * FROM fn_get_users();")

            users = cursor.fetchall()

            if order_by == "id":
                users.sort(key=lambda x: x[0])

    else:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM fn_get_users();")
            users = cursor.fetchall()

    return render(
        request,
        "users/index.html",
        {"users": users, "search_query": search_query, "order_by": order_by},
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
