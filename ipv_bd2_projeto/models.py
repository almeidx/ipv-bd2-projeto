from django.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin, Group, Permission
from django.utils import timezone

class Armazem(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    address = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=10)
    locality = models.CharField(max_length=50)


class TipoMaoDeObra(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    cost = models.FloatField()


class UtilizadorManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('type', Utilizador.TipoDeUtilizador.ADMIN)
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class Utilizador(AbstractBaseUser, PermissionsMixin):
    class TipoDeUtilizador(models.TextChoices):
        ADMIN = "AD", _("Administrador")
        FUNCIONARIO = "FU", _("Funcionário")
        CLIENTE = "CL", _("Cliente")

    id = models.AutoField(primary_key=True)
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.EmailField(unique=True)
    type = models.CharField(
        max_length=2,
        choices=TipoDeUtilizador.choices,
        default=TipoDeUtilizador.CLIENTE,
    )
    password = models.CharField(max_length=256, default='password')

    date_joined = models.DateTimeField(default=timezone.now)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    groups = models.ManyToManyField(Group, verbose_name=_("groups"), blank=True, related_name="utilizador_groups")
    user_permissions = models.ManyToManyField(
        Permission,
        verbose_name=_("user permissions"),
        blank=True,
        related_name="utilizador_user_permissions"
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = UtilizadorManager()

    def get_type_display(self):
        return dict(self.TipoDeUtilizador.choices)[self.type]

    def __str__(self):
        return self.email


class TipoDeEquipamento(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)


class Equipamento(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    created_at = models.DateField(auto_now_add=True)
    tipo_equipamento_id = models.ForeignKey(
        TipoDeEquipamento,
        on_delete=models.DO_NOTHING,
    )


class EncomendaEquipamento(models.Model):
    id = models.AutoField(primary_key=True)
    created_at = models.DateField(auto_now_add=True)
    address = models.CharField(max_length=50)
    postal_code = models.CharField(max_length=50)
    locality = models.CharField(max_length=50)
    client_id = models.ForeignKey(
        Utilizador,
        on_delete=models.DO_NOTHING,
        related_name="client_encomendaequipamento_set",
    )
    funcionario_id = models.ForeignKey(
        Utilizador,
        on_delete=models.DO_NOTHING,
        related_name="funcionario_encomendaequipamento_set",
    )


class QuantidadeEncomendaEquipamento(models.Model):
    id = models.AutoField(primary_key=True)
    amount = models.IntegerField()
    equipamento = models.ForeignKey(Equipamento, on_delete=models.DO_NOTHING)
    encomenda = models.ForeignKey(EncomendaEquipamento, on_delete=models.DO_NOTHING)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["equipamento", "encomenda"],
                name="unique_equipamento_encomenda",
            )
        ]


class Fornecedor(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    address = models.CharField(max_length=50)
    postal_code = models.CharField(max_length=50)
    locality = models.CharField(max_length=50)
    email = models.EmailField()


class Componente(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50)
    created_at = models.DateField(auto_now_add=True)
    cost = models.FloatField()
    fornecedor_id = models.ForeignKey(Fornecedor, on_delete=models.DO_NOTHING)


class EncomendaComponente(models.Model):
    id = models.AutoField(primary_key=True)
    created_at = models.DateField(auto_now_add=True)
    fornecedor_id = models.ForeignKey(Fornecedor, on_delete=models.DO_NOTHING)
    funcionario_responsavel_id = models.ForeignKey(
        Utilizador, on_delete=models.DO_NOTHING
    )
    exported = models.BooleanField(default=False)


class GuiaEntregaComponente(models.Model):
    id = models.AutoField(primary_key=True)
    created_at = models.DateField(auto_now_add=True)
    armazem_id = models.ForeignKey(Armazem, on_delete=models.DO_NOTHING)


class QuantidadeEncomendaComponente(models.Model):
    id = models.AutoField(primary_key=True)
    amount = models.IntegerField()
    componente = models.ForeignKey(Componente, on_delete=models.DO_NOTHING)
    encomenda = models.ForeignKey(EncomendaComponente, on_delete=models.DO_NOTHING)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["componente", "encomenda"], name="unique_componente_encomenda"
            )
        ]


class QuantidadeGuiaEntregaComponente(models.Model):
    id = models.AutoField(primary_key=True)
    amount = models.IntegerField()
    componente = models.ForeignKey(Componente, on_delete=models.DO_NOTHING)
    guia_entrega = models.ForeignKey(GuiaEntregaComponente, on_delete=models.DO_NOTHING)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["componente", "guia_entrega"],
                name="unique_componente_guia_entrega",
            )
        ]


class Expedicao(models.Model):
    sent_at = models.DateField(auto_now_add=True)
    truck_license = models.CharField(null=True, max_length=50)
    delivery_date_expected = models.DateField(auto_now_add=True)
    encomenda_id = models.OneToOneField(
        EncomendaEquipamento, on_delete=models.DO_NOTHING, primary_key=True
    )


class RegistoProducao(models.Model):
    id = models.AutoField(primary_key=True)
    started_at = models.DateField(auto_now_add=True)
    ended_at = models.DateField(auto_now_add=True)
    delivery_id = models.ForeignKey(Expedicao, on_delete=models.DO_NOTHING)
    tipo_mao_de_obra_id = models.ForeignKey(TipoMaoDeObra, on_delete=models.DO_NOTHING)
    armazem_id = models.ForeignKey(Armazem, on_delete=models.DO_NOTHING)
    funcionario_id = models.ForeignKey(Utilizador, on_delete=models.DO_NOTHING)
    equipamento_id = models.ForeignKey(Equipamento, on_delete=models.DO_NOTHING)


class QuantidadeComponenteRegistoProducao(models.Model):
    id = models.AutoField(primary_key=True)
    amount = models.IntegerField()
    componente = models.ForeignKey(Componente, on_delete=models.DO_NOTHING)
    registo_producao = models.ForeignKey(RegistoProducao, on_delete=models.DO_NOTHING)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["componente", "registo_producao"],
                name="unique_componente_registo_producao",
            )
        ]


class Fatura(models.Model):
    created_at = models.DateField(auto_now_add=True)
    contribuinte = models.CharField(max_length=50)
    encomenda_id = models.OneToOneField(
        EncomendaEquipamento, on_delete=models.DO_NOTHING, primary_key=True
    )
