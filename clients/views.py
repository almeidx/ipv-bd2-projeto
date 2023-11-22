from django.shortcuts import render

def index(request):
		return render(request, "clients/index.html")


def edit(request):
		return render(request, "clients/edit.html")


def register(request):
		return render(request, "clients/register.html")
