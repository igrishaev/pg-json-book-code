

def getin (obj, *paths):
    result = obj
    for path in paths:
        try:
            result = result[path]
        except KeyError:
            return None
    return result


data = {"a": {"b": {"c": 5}}}

print(getin(data, "a", "b", "c"))
# 5

print(getin(data, "a", "dunno", "c"))
# None
