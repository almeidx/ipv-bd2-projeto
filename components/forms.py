from django import forms


class ComponenteForm(forms.Form):
    file = forms.FileField()
