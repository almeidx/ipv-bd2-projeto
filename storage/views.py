from django.shortcuts import render
from django.db import connection, transaction
from django.shortcuts import render
from django.shortcuts import redirect
from django.db import connection

def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_armazens();")
        storages = cursor.fetchall()

    return render(request, "storage/index.html", {"storages": storages})


def edit(request, id):
		if request.method == "POST":
			with connection.cursor() as cursor:
				cursor.execute("CALL sp_edit_armazem(%s, %s, %s, %s, %s);", [
					id,
					request.POST["name"],
					request.POST['address'],
					request.POST['postal_code'],
					request.POST['locality']]
				)

			return redirect("/storage/")

		with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_armazem_by_id(%s);", [id])
			storage = cursor.fetchone()

		return render(request, "storage/edit.html", { 'storage': storage })


def register(request):
		if request.method == "POST":
			name = request.POST['name']
			address = request.POST['address']
			postal_code = request.POST['postal_code']
			locality = request.POST['locality']

			with connection.cursor() as cursor:
				cursor.execute("CALL sp_create_armazem(%s, %s, %s, %s);", [name, address, postal_code, locality])
				cursor.close()

			return redirect("/storage/")

		return render(request, "storage/register.html")
