from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from django.http import HttpResponse

def index(_request):
		return redirect("equipments/")


def create_account(request):
		return render(request, "create_account.html")


def login_view(request):
    if request.method == 'POST':
        email = request.POST['email']
        password = request.POST['password']
        user = authenticate(request, email=email, password=password)

        print(email + ' - ' + password)
        print(user)

        if user is not None:
            login(request, user)
            print(request.user)
            return redirect('/')
        else:
            return HttpResponse('Erro de autenticação')

    return render(request, 'login.html')


def logout(request):
    logout(request)
    return redirect('/')
