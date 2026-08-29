import sqlite3
from datetime import datetime
from typing import Any
from contextlib import contextmanager

import config

""" helpers """
@contextmanager
def _connection():
    conn = sqlite3.connect(config.DATABASE)

    try:
        # Settings
        conn.execute("PRAGMA foreign_keys = ON") # foreign_keys must exist
        conn.row_factory = sqlite3.Row # rows are return as dicts instead of tuple pairs

        yield conn
        conn.commit()
    except:
        conn.rollback()
        raise
    finally:
        conn.close()
def _get_time():
    return datetime.now().isoformat()

""" tables: create & drop """
def create_tables() -> bool:
    with _connection() as conn:
        # table creation helpers
        _create_conversations_table(conn)
        _create_messages_table(conn)
        
    return True # success
def drop_tables() -> bool:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""DROP TABLE IF EXISTS messages""")
        cursor.execute("""DROP TABLE IF EXISTS conversations""")
    return True
def _create_conversations_table(conn):
    cursor = conn.cursor()
    cursor.execute("""
       CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            created_at TEXT,
            updated_at TEXT
        )            
    """)
def _create_messages_table(conn):
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            role TEXT,
            content TEXT,
            created_at TEXT,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
        )   
    """)

""" basic conversation methods """
def create_conversation(title: str) -> int:
    with _connection() as conn:
        cursor = conn.cursor()
        time = _get_time()
        cursor.execute(
            "INSERT INTO conversations (title, created_at, updated_at) VALUES (?, ?, ?)",
            (title, time, time) # isoformat converts to string from datetime obj
        )
        conversation_id = cursor.lastrowid
        return {
            "conversation_id": conversation_id,
            "title": title,
            "created_at": time,
            "updated_at": time
        }
def insert_message(conversation_id: int, role: str, content: str) -> dict[str, Any]:
    with _connection() as conn:
        cursor = conn.cursor()
        time = _get_time()
        cursor.execute(
            "INSERT INTO messages (conversation_id, role, content, created_at) VALUES (?, ?, ?, ?)",
            (conversation_id, role, content, time)
        )
        cursor.execute(
            """
            UPDATE conversations
            SET updated_at = ?
            WHERE id = ?
            """,
            (time, conversation_id)
        )
        id = cursor.lastrowid
        return {
            "conversation_id": conversation_id,
            "id": id,
            "role": role,
            "content": content,
            "created_at": time
        }
def get_messages_for_id(conversation_id: int) -> list[dict[str, str]]:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT conversation_id, id, role, content, created_at FROM messages WHERE conversation_id = ? ORDER BY id",
            (conversation_id,)
        )
        messages = cursor.fetchall()
        return [dict(row) for row in messages]
def get_all_conversations() -> list[dict[str, Any]]:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            SELECT id, title, created_at, updated_at 
            FROM conversations 
            ORDER BY updated_at DESC
            """
        )
        rows = cursor.fetchall()
        return [{
            "conversation_id": row["id"],
            "title": row["title"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"]
        } for row in rows]
def delete_conversation(conversation_id: int):
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM conversations WHERE id = ?",
            (conversation_id,)
        )
def update_conversation_title(id: int, title: str):
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE conversations
            SET title = ?
            WHERE id = ?
            """,
            (title, id)
        )

""" testing """
if __name__ == "__main__":
    drop_tables()
    create_tables()
