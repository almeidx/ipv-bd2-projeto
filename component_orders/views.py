from django.shortcuts import render

def index(request):
	return render(request, "component_orders/index.html")

def register(request):
	return render(request, "component_orders/register.html")

def register_received(request):
	return render(request, "component_orders/register_received.html")

def edit(request):
	return render(request, "component_orders/edit.html")
