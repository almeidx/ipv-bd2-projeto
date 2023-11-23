from django.shortcuts import render

def index(request):
	return render(request, "attributes/index.html")

def edit(request):
    return render(request, "attributes/edit.html")

def register(request):
    return render(request, "attributes/register.html")

