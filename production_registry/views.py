from django.shortcuts import render

def index(request):
	return render(request, "production_registry/index.html")

def register(request):
	return render(request, "production_registry/register.html")
