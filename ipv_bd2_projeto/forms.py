from django.contrib.auth.forms import UserCreationForm, UserChangeForm

from .models import Utilizador


class UtilizadorCreationForm(UserCreationForm):
    class Meta:
        model = Utilizador
        fields = ("email",)


class UtilizadorChangeForm(UserChangeForm):
    class Meta:
        model = Utilizador
        fields = ("email",)
