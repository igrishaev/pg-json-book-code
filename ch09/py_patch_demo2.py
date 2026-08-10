import jsonpatch

doc_old = {
  "a": 1,
  "c": [1, 3],
  "d": True
}

doc_new = {
  "c": [1, 2, 3],
  "b": 2
}

patch = jsonpatch.JsonPatch.from_diff(doc_old, doc_new)
# <jsonpatch.JsonPatch object at 0x1095d3f10>

print(patch)
## [{"op": "remove", "path": "/a"}, {"op": "remove", "path": "/d"}, {"op": "add", "path": "/b", "value": 2}, {"op": "add", "path": "/c/1", "value": 2}]

doc_new2 = patch.apply(doc_old)

doc_new == doc_new2
## True
