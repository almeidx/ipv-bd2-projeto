from django.shortcuts import render

def index(request):
		return render(request, "users/index.html")


def edit(request, id):
		return render(request, "users/edit.html")


def register(request):
		return render(request, "users/register.html")
