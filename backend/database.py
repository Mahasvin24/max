import sqlite3
import config

""" db connection w/ setting applied"""
def get_connection():
    conn = sqlite3.connect(config.DATABASE)
    conn.execute("PRAGMA foreign_keys = ON") # setting: foreign_keys must exist
    return conn

""" high-level table creation and drop """
def create_tables() -> bool:
    conn = get_connection()

    # table creation helpers
    create_conversation_table(conn)
    create_messages_table(conn)
    
    conn.close()
    return True # success
def drop_tables() -> bool:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""DROP TABLE IF EXISTS conversations""")
    cursor.execute("""DROP TABLE IF EXISTS messages""")
    conn.commit()
    conn.close()
    return True

""" table creation helpers """
def create_conversation_table(conn):
    cursor = conn.cursor()
    cursor.execute("""
       CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT
        )            
    """)
    conn.commit()
def create_messages_table(conn):
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            role TEXT,
            content TEXT,
            created_at TEXT,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id)
        )   
    """)
    conn.commit()

""" testing """
if __name__ == "__main__":
    drop_tables()
    create_tables()

