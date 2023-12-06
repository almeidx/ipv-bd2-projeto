from django.shortcuts import render, redirect
from django.db import connection


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_components();")
        components = cursor.fetchall()

    return render(request, "components/index.html", {"components": components})


def register(request):
	if request.method == "POST":
		with connection.cursor() as cursor:
			cursor.execute("CALL sp_create_component(%s, %s, %s);", [
				request.POST['name'],
				request.POST['cost'],
				request.POST['fornecedor_id_id']
			])
			cursor.close()

		return redirect("/components/")

	with connection.cursor() as cursor:
		cursor.execute("SELECT * FROM fn_get_fornecedores();")
		sellers = cursor.fetchall()

	return render(request, "components/register.html", { 'sellers': sellers })


def edit(request, id):
	if request.method == "POST":
		with connection.cursor() as cursor:
			cursor.execute("CALL sp_edit_component(%s, %s, %s, %s);", [
				id,
				request.POST["name"],
				request.POST["cost"],
				request.POST["fornecedor_id_id"],
			])

		return redirect("/components/")

	with connection.cursor() as cursor:
		cursor.execute("SELECT * FROM fn_get_fornecedores();")
		sellers = cursor.fetchall()

	with connection.cursor() as cursor:
		cursor.execute("SELECT * FROM fn_get_component(%s);", [id])
		component = cursor.fetchone()

	return render(request, "components/edit.html", {"component": component, "sellers": sellers})


def stock(request):
	return render(request, "components/stock.html")
