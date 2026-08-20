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


p1 = [
    {"op": "add", "path": "/nums/-", "value": 1},
    {"op": "add", "path": "/nums/-", "value": 2},
    {"op": "add", "path": "/nums/-", "value": 3},
]

p2 = [
    {"op": "add", "path": "/nums/-", "value": 4},
    {"op": "add", "path": "/nums/-", "value": 5},
    {"op": "add", "path": "/nums/-", "value": 6},
]

doc = {"nums": []}

print(jsonpatch.JsonPatch(p1 + p2).apply(doc))
# {'nums': [1, 2, 3, 4, 5, 6]}
