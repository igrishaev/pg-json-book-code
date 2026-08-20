from jsonpatch import JsonPatch, PatchOperation

class IncrementOperation(PatchOperation):

    def apply(self, obj):
        subobj, part = self.pointer.to_last(obj)
        try:
            val = subobj[part]
        except (KeyError, IndexError):
            raise

        if not isinstance(val, (int, float)):
            raise TypeError(f"Value is not a number: {val}")

        try:
            value = self.operation["value"]
        except KeyError as ex:
            raise InvalidJsonPatch("The operation does not contain a 'value' member")

        subobj[part] += value
        return obj

ops = JsonPatch.operations | {
    'inc': IncrementOperation
}

JsonPatch.operations = ops

doc = {"amount": 1000}

p = JsonPatch([
    {"op": "inc", "path": "/amount", "value": 200},
    {"op": "add", "path": "/foo", "value": "a"},
    {"op": "inc", "path": "/amount", "value": 300},
    {"op": "add", "path": "/bar", "value": "b"},
])

print(p.apply(doc))
# {'amount': 1500, 'foo': 'a', 'bar': 'b'}
