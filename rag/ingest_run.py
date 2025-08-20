import argparse
import os
import json
import time
import datetime
import chromadb
from sentence_transformers import SentenceTransformer

BASE = r"C:\projects\gaslands_notebooklm_macro_package"
DB_DIR = os.path.join(BASE, "rag", "db")
COLL = "gaslands_runs"

def now_rfc3339():
    """
    Return RFC3339 UTC timestamp (e.g., 2025-08-19T20:17:00Z)
    """
    return (
        datetime.datetime.now(datetime.UTC)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )

def main():
    parser = argparse.ArgumentParser(description="Ingest prompt + reply into ChromaDB")
    parser.add_argument("--prompt", required=True, help="Path to prompt.txt")
    parser.add_argument("--reply", required=True, help="Path to last_reply.txt")
    parser.add_argument("--notebook", required=True, help="Notebook ID or URL")
    parser.add_argument("--status", default="ok", help="Run status string")
    args = parser.parse_args()

    # Load prompt and reply text safely
    prompt = (
        open(args.prompt, "r", encoding="utf-8").read().strip()
        if os.path.exists(args.prompt)
        else ""
    )
    reply = (
        open(args.reply, "r", encoding="utf-8").read().strip()
        if os.path.exists(args.reply)
        else ""
    )
    if not (prompt or reply):
        print("Nothing to ingest (both prompt and reply are empty).")
        return

    # Combine into single document
    doc_text = f"Prompt:\n{prompt}\n\nAnswer:\n{reply}".strip()
    run_id = f"{now_rfc3339()}_{int(time.time())}"

    # Initialize ChromaDB persistent client
    client = chromadb.PersistentClient(path=DB_DIR)
    coll = client.get_or_create_collection(COLL, metadata={"hnsw:space": "cosine"})

    # Embed with SentenceTransformers
    model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
    emb = model.encode([doc_text]).tolist()

    # Store in ChromaDB
    coll.add(
        ids=[run_id],
        documents=[doc_text],
        metadatas=[
            {
                "ts": now_rfc3339(),
                "notebook_url": args.notebook,
                "status": args.status,
            }
        ],
        embeddings=emb,
    )

    print(f"[ingest_run] Stored run_id={run_id} into collection '{COLL}'")

if __name__ == "__main__":
    main()
