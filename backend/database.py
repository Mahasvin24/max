import sqlite3
import config

def create_tables() -> bool:
    conn = sqlite3.connect(config.DATABASE)

    # table creation helpers
    create_conversation_table(conn)
    create_messages_table(conn)

    # setting: foreign_keys must exist
    conn.execute("PRAGMA foreign_keys = ON")
    
    conn.close()
    return True # success

def drop_tables() -> bool:
    conn = sqlite3.connect(config.DATABASE)
    cursor = conn.cursor()
    cursor.execute("""DROP TABLE IF EXISTS conversations""")
    cursor.execute("""DROP TABLE IF EXISTS messages""")
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
            role STRING,
            content STRING,
            created_at TEXT,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id)
        )   
    """)
    conn.commit()

if __name__ == "__main__":
    create_tables()

