from django.shortcuts import render, redirect

def index(request):
		return redirect("equipments/")


def login(request):
		return render(request, "login.html")


def create_account(request):
		return render(request, "create_account.html")
