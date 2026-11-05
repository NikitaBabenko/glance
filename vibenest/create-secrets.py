"""Create a private env file without putting a password in argv or stdout."""
import base64
import getpass
import os
from pathlib import Path
import secrets
import sys

import bcrypt

if len(sys.argv) != 2:
    raise SystemExit("Usage: python vibenest/create-secrets.py /private/path/glance.env")
destination = Path(sys.argv[1]).expanduser().resolve()
repository = Path(__file__).resolve().parents[1]
if destination.is_relative_to(repository):
    raise SystemExit("Choose a private folder outside this repository.")
password = getpass.getpass("Unique Glance password (16+ characters): ")
confirmation = getpass.getpass("Confirm password: ")
if password != confirmation or len(password) < 16 or len(password.encode()) > 72:
    raise SystemExit("Passwords must match, contain at least 16 characters, and fit in 72 UTF-8 bytes.")
password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12)).decode()
secret_key = base64.b64encode(secrets.token_bytes(64)).decode()
fd = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as output:
    output.write(f"GLANCE_SECRET_KEY={secret_key}\nGLANCE_PASSWORD_HASH={password_hash}\n")
print("Private environment file created. Import it in VibeNest; do not commit or share it.")
