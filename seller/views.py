from django.shortcuts import render, redirect
from django.db import connection


def index(request):
		with connection.cursor() as cursor:
				cursor.execute("SELECT * FROM fn_get_fornecedores();")
				sellers = cursor.fetchall()

		context = {	"sellers": sellers }
		if request.GET.get("delete_fail"):
			context["delete_fail"] = True # type: ignore

		return render(request, "seller/index.html", context)


def register(request):
	if request.method == "POST":
		name = request.POST['name']
		address = request.POST['address']
		email = request.POST['email']
		postal_code = request.POST['postal_code']
		locality = request.POST['locality']

		with connection.cursor() as cursor:
			cursor.execute("CALL sp_create_fornecedor(%s, %s, %s, %s, %s);", [
				name,
				address,
				postal_code,
				locality,
				email

			])
			cursor.close()

		return redirect("/seller/")

	return render(request, "seller/register.html")


def edit(request, id):
	if request.method == "POST":
			with connection.cursor() as cursor:
				cursor.execute("CALL sp_edit_fornecedor(%s, %s, %s, %s, %s, %s);", [
					id,
					request.POST['name'],
					request.POST['address'],
					request.POST['postal_code'],
					request.POST['locality'],
					request.POST['email'],
				])

			return redirect("/seller/")

	with connection.cursor() as cursor:
			cursor.execute("SELECT * FROM fn_get_fornecedor_by_id(%s);", [id])
			seller = cursor.fetchone()

	return render(request, "seller/edit.html", { 'seller': seller })


def delete(request, id):
	with connection.cursor() as cursor:
		cursor.execute("SELECT public.fn_delete_fornecedor_by_id(%s);", [id])
		result = cursor.fetchone()
		deleted_successfully = result[0] if result is not None else False

	if deleted_successfully:
		return redirect("/seller/")
	else:
		return redirect("/seller/?delete_fail=1")
