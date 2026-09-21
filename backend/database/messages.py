from typing import Any

from helpers import _connection, _get_time

""" Table Schema """
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

""" CREATE """
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


""" READ """
def get_messages_for_id(conversation_id: int) -> list[dict[str, str]]:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT conversation_id, id, role, content, created_at FROM messages WHERE conversation_id = ? ORDER BY id",
            (conversation_id,)
        )
        messages = cursor.fetchall()
        return [dict(row) for row in messages]