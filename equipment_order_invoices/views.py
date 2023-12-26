from django.shortcuts import render


def index(request):
    return render(request, "equipment_order_invoices/index.html")


def info(request, id):
    return render(request, "equipment_order_invoices/info.html")


def register(request, id):
    return render(request, "equipment_order_invoices/info_compra.html")
