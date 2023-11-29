from django.shortcuts import render
from django.shortcuts import redirect
from django.db import connection

def index(request):
	with connection.cursor() as cursor:
		cursor.execute("CALL sp_get_tipo_equipamentos();")
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

		return redirect("/equipment_type")

	return render(request, "equipment_type/register.html")


def edit(request, id):
	return render(request, "equipment_type/edit.html")

