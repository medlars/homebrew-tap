import json
import plistlib
import py_compile
import re
import subprocess
import sys
import tomllib
from pathlib import Path

import yaml

TEXT_SUFFIXES = (".md", ".mdx", ".html", ".js", ".ts", ".mjs", ".css", ".txt")
CONFLICT = re.compile(r"^(<{7}|>{7}) ", re.MULTILINE)
PARSE_ERRORS = (OSError, ValueError, UnicodeDecodeError, SyntaxError, py_compile.PyCompileError,
                tomllib.TOMLDecodeError, yaml.YAMLError, plistlib.InvalidFileException)


def run_tool(cmd: list[str]) -> None:
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode:
        raise ValueError(proc.stderr or proc.stdout)


def check(path: Path) -> str:
    kind = path.suffix.lower().lstrip(".")
    if kind == "py":
        py_compile.compile(str(path), doraise=True)
    elif kind == "sh":
        run_tool(["bash", "-n", str(path)])
    elif kind == "rb":
        run_tool(["ruby", "-c", str(path)])
    elif kind == "json":
        json.loads(path.read_text(encoding="utf-8"))
    elif kind == "toml":
        tomllib.loads(path.read_text(encoding="utf-8"))
    elif kind in {"yml", "yaml"}:
        list(yaml.safe_load_all(path.read_text(encoding="utf-8")))
    elif kind == "plist":
        plistlib.loads(path.read_bytes())
    else:
        kind = ""
    if (kind or path.suffix.lower() in TEXT_SUFFIXES) and CONFLICT.search(path.read_text(encoding="utf-8", errors="ignore")):
        raise ValueError("merge-conflict marker committed")
    return kind


def main() -> int:
    listed = subprocess.run(["git", "ls-files", "-z"], capture_output=True, text=True, check=True).stdout
    counts: dict[str, int] = {}
    failures: list[str] = []
    for name in filter(None, listed.split("\0")):
        path = Path(name)
        if path.is_symlink():
            continue
        try:
            kind = check(path)
        except PARSE_ERRORS as exc:
            lines = str(exc).strip().splitlines() or [type(exc).__name__]
            failures.append(f"{name}: {lines[-1][:200]}")
            continue
        if kind:
            counts[kind] = counts.get(kind, 0) + 1
    print(f"checked {sum(counts.values())} files: {json.dumps(counts, sort_keys=True)}")
    for line in failures:
        print(f"::error::{line}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
