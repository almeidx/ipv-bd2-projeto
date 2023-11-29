from django.shortcuts import render

def index(request):
		return render(request, "seller/index.html")


def edit(request, id):
		return render(request, "seller/edit.html")


def register(request):
		return render(request, "seller/register.html")
