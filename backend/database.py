import sqlite3
import config
from datetime import datetime

""" helpers """
def _get_connection():
    conn = sqlite3.connect(config.DATABASE)
    conn.execute("PRAGMA foreign_keys = ON") # setting: foreign_keys must exist
    return conn
def _get_time():
    return datetime.now().isoformat()

""" tables: create & drop """
def create_tables() -> bool:
    conn = _get_connection()

    # table creation helpers
    _create_conversations_table(conn)
    _create_messages_table(conn)
    
    conn.close()
    return True # success
def drop_tables() -> bool:
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute("""DROP TABLE IF EXISTS messages""")
    cursor.execute("""DROP TABLE IF EXISTS conversations""")
    conn.commit()
    conn.close()
    return True
def _create_conversations_table(conn):
    cursor = conn.cursor()
    cursor.execute("""
       CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT
        )            
    """)
    conn.commit()
def _create_messages_table(conn):
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
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO conversations (created_at) VALUES (?)",
        (_get_time(),) # isoformat converts to string from datetime obj
    )
    conn.commit()
    conversation_id = cursor.lastrowid
    conn.close()
    return conversation_id
def add_message(conversation_id, role, content):
    conn = _get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO messages (conversation_id, role, content, created_at) VALUES (?, ?, ?, ?)",
        (conversation_id, role, content, _get_time())
    )
    conn.commit()
    conn.close()
def messages_for_id(conversation_id) -> list[dict[str, str]]:
    conn = _get_connection()
    conn.row_factory = sqlite3.Row # setting to return as dict rather than tuple, method specific
    cursor = conn.cursor()
    cursor.execute(
        "SELECT role, content FROM messages WHERE conversation_id = ? ORDER BY id",
        (conversation_id,)
    )
    messages = cursor.fetchall()
    conn.close()
    return [dict(row) for row in messages]
    

""" testing """
if __name__ == "__main__":
    drop_tables()
    create_tables()
