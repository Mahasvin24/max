import sqlite3
import config
from datetime import datetime

""" helpers """
def get_connection():
    conn = sqlite3.connect(config.DATABASE)
    conn.execute("PRAGMA foreign_keys = ON") # setting: foreign_keys must exist
    return conn
def get_time():
    return datetime.now().isoformat()

""" tables: create & drop """
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
    cursor.execute("""DROP TABLE IF EXISTS messages""")
    cursor.execute("""DROP TABLE IF EXISTS conversations""")
    conn.commit()
    conn.close()
    return True
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

""" basic conversation methods """
def create_conversation() -> int:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO conversations (created_at) VALUES (?)",
        (get_time(),) # isoformat converts to string from datetime obj
    )
    conn.commit()
    conversation_id = cursor.lastrowid
    conn.close()
    return conversation_id
def add_message(conversation_id, role, content):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO messages (conversation_id, role, content, created_at) VALUES (?, ?, ?, ?)",
        (conversation_id, role, content, get_time())
    )
    conn.commit()
    conn.close()

""" testing """
if __name__ == "__main__":
    drop_tables()
    create_tables()
