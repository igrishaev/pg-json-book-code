

from django.db.models.signals import pre_save
from django.dispatch import receiver

from project.models import Application, History

@receiver(pre_save, sender=Application)
def save_history(sender, instance, **kwargs):
    History.objects.create(
        pk=instance.id,
        entity='application',
        operation='UPDATE',
        doc=instance.doc
    )


class Application(models.Model):
    # fields
    def save():
        # create a history entry
        super().save()
