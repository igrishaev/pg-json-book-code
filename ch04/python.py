

users = [
    {"id": 101, "name": "Ivan", "age": 14},
    {"id": 202, "name": "John", "age": 34},
    {"id": 303, "name": "Juan", "age": 51},
]

id_to_user = {
    user["id"]: user for user in users
}

user = id_to_user[202]
print(user)
# {'id': 202, 'name': 'John', 'age': 34}


id_to_index = {
    user["id"]: i for i, user in enumerate(users)
}

index = id_to_index[202] # 1
user = users[index]
print(user)
# {'id': 202, 'name': 'John', 'age': 34}

name_to_ids = {
    'Ivan': [101],
    'John': [202, 345, 582],
}
