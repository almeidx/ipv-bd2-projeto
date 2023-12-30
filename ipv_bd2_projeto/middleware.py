from django.db import connection
from django.shortcuts import redirect


class LoginRequiredMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        print(request.path)

        with connection.cursor() as cursor:
            cursor.execute("SELECT fn_check_if_there_are_users()")
            result = cursor.fetchone()
            at_least_one_user = result[0] if result else False

        if at_least_one_user:
            if request.path != "/login/" and not request.user.is_authenticated:
                return redirect("/login")
        else:
            if (
                request.path != "/login/"
                and request.path != "/users/register/"
                and not request.user.is_authenticated
            ):
                return redirect("/users/register/")

        return self.get_response(request)
