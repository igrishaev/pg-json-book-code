import json
import re

def needs_quoting(lexem):
    return re.search("[^a-zA-Z0-9_]+", lexem)

def maybe_quote(lexem):
    if needs_quoting(lexem):
        return '"%s"' % (lexem, )
    else:
        return lexem

def json_path(path, op, value):
    return "$.%s %s %s" % (
        ".".join([
            maybe_quote(part) for part in path
        ]),
        op,
        json.dumps(value)
    )


if __name__ == "__main__":

    print(json_path(["departments", "users", "email"], "==", "test@test.com"))
    # $.departments.users.email == "test@test.com"

    print(json_path(["test", "full-name", "is-active?"], "==", True))
    # $.test."full-name"."is-active?" == true




Built-in
https://docs.djangoproject.com/en/6.0/topics/db/queries/#querying-jsonfield

Func
https://stackoverflow.com/questions/76257375/can-i-use-a-jsonpath-predicate-in-a-filter

Lookups
https://docs.djangoproject.com/en/6.0/howto/custom-lookups/

from django.db.models import Lookup
from django.db.models import Field

class JsonbAtAt(Lookup):
    lookup_name = "atat"

    def as_sql(self, compiler, connection):
        ...
        return "%s @@ %s" % (column, path), params


Field.register_lookup(JsonbAtAt)

...

Applications.objects.filter(doc__atat=(path, op, value))



Extra/Raw
https://docs.djangoproject.com/en/6.0/ref/models/querysets/#extra
