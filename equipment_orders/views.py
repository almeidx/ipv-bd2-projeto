from django.shortcuts import render

def index(request):
	return render(request, "equipment_orders/index.html")

def register(request):
	return render(request, "equipment_orders/register.html")

def edit(request):
	return render(request, "equipment_orders/edit.html")
