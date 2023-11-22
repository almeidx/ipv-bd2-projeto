from django.shortcuts import render

def index(request):
		return render(request, "index.html")


def login(request):
		return render(request, "login.html")


def create_account(request):
		return render(request, "create_account.html")
