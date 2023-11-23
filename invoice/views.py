from django.shortcuts import render


def index(request):
	return render(request, "invoice/index.html")


def info(request, id):
	return render(request, "invoice/info.html")


def shipping(request):
	return render(request, "invoice/shipping.html")
