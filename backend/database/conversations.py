from typing import Any

from .helpers import _connection, _get_time

""" Table Schema """
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

""" CREATE """
def create(title: str) -> dict[str, Any]:
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

""" READ """
def list_all() -> list[dict[str, Any]]:
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

""" DELETE """
def delete(conversation_id: int):
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM conversations WHERE id = ?",
            (conversation_id,)
        )

""" UPDATE """
def update_title(conversation_id: int, title: str):
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE conversations
            SET title = ?
            WHERE id = ?
            """,
            (title, conversation_id)
        )

""" Helpers """
def exists(conversation_id: int) -> bool:
    with _connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1
                FROM conversations
                WHERE id = ?
            );
        """, (conversation_id,))
        row = cursor.fetchone()
        return bool(row[0])


def fetch_conversation_previews() -> dict[str, str]:
    # conn = _connection()
    # cursor = conn.cursor()

    rows = list_all()

    res = {}
    for convo in rows:
        res[convo["conversation_id"]] = f"Conversation Title: {convo["title"]}"

    return res