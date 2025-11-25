
users = [
    {"id": 1, "name": "Ivan", "age": 14},
    {"id": 2, "name": "John", "age": 34},
    {"id": 3, "name": "Juan", "age": 51},
]

def subset(d, *keys):
    return {k: d[k] for k in keys}

new_users = [
    subset(user, "id", "name") for user in users
    if user["age"] > 18
]

[{'id': 2, 'name': 'John'},
 {'id': 3, 'name': 'Juan'}]


profiles = [
    {"user_id": 1, "job": "teacher", "is_open": True},
    {"user_id": 2, "job": "programmer", "is_open": False},
    {"user_id": 3, "job": "cook", "is_open": True},
]

def index_by(field, rows):
    return {row[field]: row for row in rows}

profile_index = index_by("user_id", profiles);

result = []
for user in users:
    user_id = user["id"]
    profile = profile_index[user_id]
    if user["age"] > 18 and profile["is_open"]:
        row = {**user, **profile}
        result.append(row)

[{'id': 3,
  'name': 'Juan',
  'age': 51,
  'user_id': 3,
  'job': 'cook',
  'is_open': True}]
