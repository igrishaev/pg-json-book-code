import json

def json_path(path, op, value):
    return "$.%s %s %s" % (
        ".".join([
            '"%s"' % (part, ) for part in path

        ]),
        op,
        json.dumps(value)
    )


if __name__ == "__main__":
    print(json_path(["departments", "users", "email"], "==", "test@test.com"))


# $."departments"."users"."email" == "test@test.com"
