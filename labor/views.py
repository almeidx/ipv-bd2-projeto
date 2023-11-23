from django.shortcuts import render


def index(request):
	return render(request, "labor/index.html")

def edit(request):
    return render(request, "labor/edit.html")

def register(request):
    return render(request, "labor/register.html")
