from django.shortcuts import render, redirect
from django.db import connection

def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos();")
        equipments = cursor.fetchall()

    return render(request, "equipments/index.html", {"equipments": equipments})


def register(request):
	if request.method == "POST":
			name = request.POST['name']
			tipo_equipment_id_id = request.POST['tipo_equipment_id_id']

			with connection.cursor() as cursor:
					cursor.execute("CALL sp_create_equipment(%s, %s);", [name, tipo_equipment_id_id])
					cursor.close()

			return redirect("/equipments/")

	with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_tipo_equipamentos();")
			equipment_types = cursor.fetchall()

	return render(request, "equipments/register.html", { 'equipment_types': equipment_types })


def edit(request, id):
	if request.method == "POST":
			with connection.cursor() as cursor:
					cursor.execute("CALL sp_edit_tipo_equipamento(%s, %s);", [
						id,
						request.POST["name"],
						request.POST["tipo_equipment_id_id"]
					])

			return redirect("/equipments/")

	with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_equipamento_by_id(%s);", [id])
			equipment = cursor.fetchone()

	with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_tipo_equipamentos();")
			equipment_types = cursor.fetchall()

	return render(request, "equipments/edit.html", { 'equipment_types': equipment_types, 'equipment': equipment })


def stock(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_equipamentos();")
        equipments = cursor.fetchall()

    return render(request, "equipments/stock.html", {"equipments": equipments})

