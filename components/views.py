from django.shortcuts import render


def index(request):
	return render(request, "components/index.html")


def register(request):
	return render(request, "components/register.html")


def edit(request):
	return render(request, "components/edit.html")

def list_stock(request):
	return render(request, "components/list_stock.html")


def list_orders(request):
	return render(request, "components/list_orders.html")


def register_order(request):
	return render(request, "components/register_order.html")
