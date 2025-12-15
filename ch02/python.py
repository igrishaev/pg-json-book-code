

class JSONField(fields.TextFiled):
    db_type = "jsonb"

    def from_db_value(self, value, expression, connection):
        return json.loads(value, **self.decoder_kwargs)

    def get_prep_value(self, value):
        return json.dumps(value, **self.encoder_kwargs)


from django.db import models
import jsonfield

class Profile(models.Model):
    extra_data = jsonfield.JSONField()

...

profile.extra_data = {
    "google_id": 31152234236,
    "twitter_id": 2477313462,
}
profile.save()
