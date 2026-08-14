

from django.db.models.signals import pre_save
from django.dispatch import receiver

from project.models import Application, History

@receiver(pre_save, sender=Application)
def save_history(sender, instance, **kwargs):
    if not instance.pk:
        return
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


##


import jsonpatch
from django.db.models.signals import pre_save
from django.forms.models import model_to_dict


@receiver(pre_save, sender=Application)
def save_patch(sender, instance, **kwargs):

    if not instance.pk:
        return

    try:
        app_old = Application.objects.get(pk=instance.pk)
    except sender.DoesNotExist:
        return

    patch = jsonpatch.JsonPatch.from_diff(app_old.doc, instance.doc)

    History.objects.create(
        pk=instance.id,
        entity='application',
        ...
        patch=patch.to_string()
    )


# https://django-model-utils.readthedocs.io/en/latest/utilities.html#field-tracker



from django.db import models
from model_utils import FieldTracker

class Application(models.Model):
    doc = JSONField(...)
    ...
    tracker = FieldTracker()


app = Application.objects.get(pk=...)
app.doc["extra"] = 123
app.save()


@receiver(pre_save, sender=Application)
def save_patch(sender, instance, **kwargs):

    if not instance.pk:
        return

    doc_old = instance.tracker.previous("doc")
    if not doc_old:
        return

    patch = jsonpatch.JsonPatch.from_diff(doc_old, instance.doc)

    History.objects.create(
        pk=instance.id,
        entity='application',
        ...
        patch=patch.to_string()
    )
