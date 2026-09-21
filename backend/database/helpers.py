import sqlite3
from datetime import datetime
from contextlib import contextmanager

import config

""" database connection """
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

""" current time """
def _get_time():
    return datetime.now().isoformat()