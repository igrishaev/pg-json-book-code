

import pytest

TEST_DB_URL = "sqlite:///:memory:"

@pytest.fixture(scope="session")
def db_conn():
    """
    Bootstrap a database connection for the entire test suite.
    """
    conn = create_connection(TEST_DB_URL)
    yield conn
    close_connection(conn)


def test_jsonb_string_agg(db_conn):
    query = "select jsonb_string_agg(?::text, ?::jsonb) as val"
    result = db_conn.execute(query, (', ', [1, 2, 3]))
    assert result[0].val = "1, 2, 3"



@pytest.mark.parametrize("sep, array, expected", [
    (", ",  [1, 2, 3],             "1, 2, 3"),
    (" | ", ["test", false, 42.9], "test | false | 42.9"),
    (None,  None,                  None),
])
def test_jsonb_string_agg_args(db_conn, sep, array, expected):
    query = "select jsonb_string_agg(?::text, ?::jsonb) as val"
    result = db_conn.execute(query, (sep, array))
    assert result[0].val = expected
