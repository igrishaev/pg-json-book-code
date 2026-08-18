import jsonpatch

# declare two documents
doc_old = {
  "a": 1,
  "c": [1, 3],
  "d": True
}

doc_new = {
  "c": [1, 2, 3],
  "b": 2
}

# create a patch object
patch = jsonpatch.JsonPatch.from_diff(doc_old, doc_new)

# get JSON representation of the patch
str(patch)
# [{"op": "remove", "path": "/a"}, {"op": "remove", "path": "/d"}, {"op": "add", "path": "/b", "value": 2}, {"op": "add", "path": "/c/1", "value": 2}]

# Apply the patch to the old document
doc_new2 = patch.apply(doc_old)

# Both new docs are equal
doc_new == doc_new2
# True
