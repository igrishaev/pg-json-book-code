import jsonpatch

doc = {}
patches = [
    [{"op": "add", "path": "/a", "value": 1}],
    [{"op": "add", "path": "/b", "value": 2}],
]

for patch in patches:
    p = jsonpatch.JsonPatch(patch)
    doc = p.apply(doc)

print(doc)
# {'a': 1, 'b': 2}


import jsonpatch
from functools import reduce

def step_fn(acc, patch):
    p = jsonpatch.JsonPatch(patch)
    return p.apply(acc)

doc = reduce(step_fn, patches, {})
print(doc)
# {'a': 1, 'b': 2}
