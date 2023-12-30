from django.db import connection
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.http import HttpResponse


def index(_request):
    return redirect("equipments/")


def login_view(request):
    if request.method == "POST":
        email = request.POST["email"]
        password = request.POST["password"]
        user = authenticate(request, email=email, password=password)

        if user is not None:
            login(request, user)
            return redirect("/")
        else:
            return HttpResponse("Erro de autenticação")

    with connection.cursor() as cursor:
        cursor.execute("SELECT fn_check_if_there_are_users()")
        result = cursor.fetchone()
        at_least_one_user = result[0] if result else False

    return render(request, "login.html", {"at_least_one_user": at_least_one_user})


def logout_view(request):
    logout(request)
    return redirect("/")
