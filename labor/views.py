from django.shortcuts import render, redirect
from django.db import connection


def index(request):
	with connection.cursor() as cursor:
		cursor.execute("SELECT * FROM fn_get_tipo_mao_obra();")
		labors = cursor.fetchall()

	context = {	"labors": labors }
	if request.GET.get("delete_fail"):
		context["delete_fail"] = True # type: ignore

	return render(request, "labor/index.html", context)


def delete(request, id):
	with connection.cursor() as cursor:
		cursor.execute("SELECT public.fn_delete_labor_by_id(%s);", [id])
		result = cursor.fetchone()
		deleted_successfully = result[0] if result is not None else False

	if deleted_successfully:
		return redirect("/labor/")
	else:
		return redirect("/labor/?delete_fail=1")


def edit(request, id):
        if request.method == "POST":
            with connection.cursor() as cursor:
                cursor.execute ("CALL sp_edit_tipo_mao_de_obra(%s, %s, %s);", [
                    id,
                    request.POST["name"],
                    request.POST['cost']]
                )

            return redirect("/labor/")

        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM fn_get_tipo_mao_obra_by_id(%s);", [id])
            labor = cursor.fetchone()

        return render(request, "labor/edit.html", { 'labor': labor })


def register(request):
    if request.method == "POST":
        name = request.POST['name']
        cost = request.POST['cost']

        with connection.cursor() as cursor:
            cursor.execute("CALL sp_create_tipo_mao_obra(%s, %s);", [name, cost])
            cursor.close()

        return redirect("/labor/")

    return render(request, "labor/register.html")
