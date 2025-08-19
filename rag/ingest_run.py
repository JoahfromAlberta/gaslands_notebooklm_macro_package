import argparse, os, json, time, datetime
import chromadb
from sentence_transformers import SentenceTransformer

BASE = r"C:\projects\gaslands_notebooklm_macro_package"
DB_DIR = os.path.join(BASE, "rag", "db")
COLL = "gaslands_runs"

def now_iso():
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--reply", required=True)
    ap.add_argument("--notebook", required=True)
    ap.add_argument("--status", default="ok")
    args = ap.parse_args()

    prompt = open(args.prompt, "r", encoding="utf-8").read().strip() if os.path.exists(args.prompt) else ""
    reply  = open(args.reply,  "r", encoding="utf-8").read().strip() if os.path.exists(args.reply)  else ""
    if not (prompt or reply):
        return

    doc_text = f"Prompt:\n{prompt}\n\nAnswer:\n{reply}".strip()
    run_id = f"{now_iso()}_{int(time.time())}"

    client = chromadb.PersistentClient(path=DB_DIR)
    coll = client.get_or_create_collection(COLL, metadata={"hnsw:space":"cosine"})

    model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
    emb = model.encode([doc_text]).tolist()

    coll.add(
        ids=[run_id],
        documents=[doc_text],
        metadatas=[{
            "ts": now_iso(),
            "notebook_url": args.notebook,
            "status": args.status
        }],
        embeddings=emb
    )

if __name__ == "__main__":
    main()
