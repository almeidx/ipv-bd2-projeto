from django.shortcuts import render


def index(request):
	return render(request, "components/index.html")


def register(request):
	return render(request, "components/register.html")


def edit(request):
	return render(request, "components/edit.html")


def stock(request):
	return render(request, "components/stock.html")
