from django.shortcuts import render

def index(request):
		return render(request, "storage/index.html")


def edit(request, id):
		return render(request, "storage/edit.html")


def register(request):
		return render(request, "storage/register.html")
