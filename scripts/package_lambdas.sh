#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/backend/lambdas"
DIST_DIR="$ROOT_DIR/backend/dist"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/*.zip

python3 - "$SOURCE_DIR" "$DIST_DIR" <<'PY'
import pathlib
import sys
import zipfile

source_dir = pathlib.Path(sys.argv[1])
dist_dir = pathlib.Path(sys.argv[2])
handlers = ["tasks_handler", "generate_handler", "notification_worker"]
shared = ["common"]

for handler in handlers:
    zip_path = dist_dir / f"{handler}.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for entry in shared + [handler]:
            base = source_dir / entry
            for path in base.rglob("*"):
                if path.is_file() and "__pycache__" not in path.parts:
                    archive.write(path, path.relative_to(source_dir))
    print(f"Created {zip_path}")
PY
