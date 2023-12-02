from django.shortcuts import render
from django.shortcuts import redirect
from django.db import connection

def index(request):
	with connection.cursor() as cursor:
		cursor.execute("SELECT * FROM fn_get_tipo_equipamentos();")
		equipment_types = cursor.fetchall()

	return render(request, "equipment_type/index.html", {
		"equipment_types": equipment_types,
	})


def register(request):
	if request.method == "POST":
		name = request.POST['name']

		with connection.cursor() as cursor:
			cursor.execute("CALL sp_create_tipo_equipamento(%s);", [name])
			cursor.close()

		return redirect("/equipments/types")

	return render(request, "equipment_type/register.html")


def edit(request, id):
	if request.method == "POST":
			with connection.cursor() as cursor:
				cursor.execute("SELECT * FROM fn_get_tipo_equipamento(%s);", [id])
				equipment_types = cursor.fetchone()

			print("tipo equipamentos", equipment_types)

			with connection.cursor() as cursor:
				cursor.execute("CALL sp_edit_tipo_equipamento(%s, %s);", [
					id,
					request.POST["name"]
				])

			return redirect("/equipments/types")

	with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_tipo_equipamento(%s);", [id])
			equipment_type = cursor.fetchone()

	return render(request, "equipment_type/edit.html", { 'equipment_type': equipment_type })

