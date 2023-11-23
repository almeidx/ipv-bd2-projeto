from django.shortcuts import render

def index(request):
	return render(request, "equipments/index.html")


def register(request):
	return render(request, "equipments/register.html")


def edit(request, id):
	return render(request, "equipments/edit.html")


def stock(request):
	return render(request, "equipments/stock.html")


def production_regestry(request):
	return render(request, "equipments/production_regestry.html")
