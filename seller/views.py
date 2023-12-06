from django.shortcuts import render, redirect
from django.db import connection


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM fn_get_fornecedores();")
        sellers = cursor.fetchall()

    return render(request, "seller/index.html", {"sellers": sellers})


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



