import json
import jsonpatch

patch = jsonpatch.JsonPatch.from_string("""
[
    {
        "op": "remove",
        "path": "/d"
    },
    {
        "op": "replace",
        "path": "/c/1",
        "value": 2
    },
    {
        "op": "add",
        "path": "/c/2",
        "value": 3
    },
    {
        "op": "remove",
        "path": "/a"
    },
    {
        "op": "add",
        "path": "/b",
        "value": 2
    }
]
""")

doc_old = json.loads("""
{
  "a": 1,
  "c": [1, 3],
  "d": true
}
""")

doc_new = patch.apply(doc_old)

print(doc_new)
## {'c': [1, 2, 3], 'b': 2}


# src = {'foo': 'bar', 'numbers': [1, 3, 4, 8]}
# dst = {'baz': 'qux', 'numbers': [1, 4, 7]}
# patch = jsonpatch.JsonPatch.from_diff(src, dst)
