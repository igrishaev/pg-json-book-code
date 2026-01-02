
uuid = generate_v7_uuid()

conn.execute(
  "insert into applications(id, doc) values (?, ?)", (
    uuid,
    {"some": "application"}
  )
)

# --

result = conn.execute(
  "insert into applications(doc) values (?) returning id",
  ({"some": "application"}, )
)

app_uuid = result[0]["id"]

conn.execute(
  "insert into some_entity(app_id, doc) values (?, ?)", (
    app_uuid,
    {"some": "entity"}
  )
)

# --

result = conn.execute(
  "select * from applications where id = ?",
  (app_uuid, )
)

app_id = result["id"]
app = result[0]["doc"]

app["status"] = "pending"

conn.execute(
  "update applications set doc = ? where id = ?",
  (app, app_id, )
)

# --

conn.with_transaction() as tx:
  result = tx.execute("select ... for update")
  ...
  tx.execute("update ... ")

# --



conn.execute(
  "update applications set doc || ? where id = ?", (
    {
      "status": "pending",
      "updated_by": {
          "id": "<UUID>",
          "email": "ivan@acme.com",
          "name": "Ivan Petrov"
      }
    },
    app_id
  )
)

# --


app = Application.get_by_id("<UUID>")

if app is None:
    app = Application(...)
    app.save
else:
    app.status = "pending"
    app.save()
