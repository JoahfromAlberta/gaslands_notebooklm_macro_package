# rag/retrieve.py
import argparse, os, sys, re, json
from pathlib import Path
import chromadb

MARKER_RE = re.compile(r'^\s*\[(CONTEXT|LAST_REPLY|USER_PROMPT)\]\s*$', re.IGNORECASE)
LABEL_RE  = re.compile(r'^\s*(Prompt:|Answer:)\s*', re.IGNORECASE)

def read_utf8(path: Path) -> str:
    if not path.exists(): return ""
    raw = path.read_bytes()
    txt = raw.decode("utf-8", errors="replace")
    # strip BOM + ZWSP and normalize newlines
    txt = re.sub(r'^[\ufeff\u200b]+', '', txt)
    return "\n".join(txt.splitlines()).strip()

def clean_piece(s: str) -> str:
    lines = []
    for line in s.splitlines():
        if MARKER_RE.match(line):   # skip our section headers if they leaked into docs
            continue
        line = LABEL_RE.sub('', line)  # drop "Prompt:" / "Answer:"
        line = line.strip("\ufeff\u200b ").rstrip()
        if line:
            lines.append(line)
    # collapse multiple separators that might have been stored
    out = "\n".join(lines).strip()
    out = re.sub(r'(?:\n?---\n?)+', '\n', out)
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--query-file", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--k", type=int, default=4)
    args = ap.parse_args()

    root = Path(__file__).resolve().parents[1]  # …\gaslands_notebooklm_macro_package
    uiv  = root / "uivision_macro"
    last_reply_path = uiv / "last_reply.txt"

    query = read_utf8(Path(args.query_file))
    last_reply = read_utf8(last_reply_path)

    client = chromadb.PersistentClient(path=str((root / "rag" / "db").resolve()))
    col = client.get_or_create_collection("gaslands")

    if not query:
        Path(args.out).write_text("", encoding="utf-8")
        return

    res = col.query(query_texts=[query], n_results=max(1, args.k))
    docs = res.get("documents", [[]])[0]
    dists = res.get("distances", [[]])[0]

    seen = set()
    cleaned = []
    for i, doc in enumerate(docs):
        piece = clean_piece(doc or "")
        if not piece:
            continue
        if last_reply and piece.strip() == last_reply.strip():
            continue
        key = piece.lower()
        if key in seen:
            continue
        seen.add(key)
        score = (1.0 - float(dists[i])) if i < len(dists) else 0.0
        cleaned.append((piece, score))

    # write in the same visual format, but with cleaned content only
    out_lines = []
    for idx, (piece, score) in enumerate(cleaned, 1):
        out_lines.append(f"[hit {idx} score={score:.4f}]")
        out_lines.append(piece)
        out_lines.append("\n---\n")
    Path(args.out).write_text("\n".join(out_lines).strip() + "\n", encoding="utf-8")

if __name__ == "__main__":
    main()

