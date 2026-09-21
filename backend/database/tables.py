from helpers import _connection
from conversations import _create_conversations_table
from messages import _create_messages_table

""" create tables """
def create_tables() -> bool:
    with _connection() as conn:
        # table creation helpers
        _create_conversations_table(conn)
        _create_messages_table(conn)

    return True # success

""" drop all tables """
def drop_tables() -> bool:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""DROP TABLE IF EXISTS messages""")
        cursor.execute("""DROP TABLE IF EXISTS conversations""")
    return True


""" when run: clear db """
if __name__ == "__main__":
    drop_tables()
    create_tables()