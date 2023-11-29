from django.shortcuts import render


def index(request):
	return render(request, "invoice/index.html")


def info(request, id):
	return render(request, "invoice/info_expedicao.html")


def info_expedicao(request):
	return render(request, "invoice/info_expedicao.html")


def create(request):
	return render(request, "invoice/info_compra.html")


def shipping(request):
	return render(request, "invoice/shipping.html")
