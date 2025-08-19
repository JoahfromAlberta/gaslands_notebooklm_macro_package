# Gaslands NotebookLM Macro Package

[![CI](https://github.com/JoahfromAlberta/gaslands_notebooklm_macro_package/actions/workflows/ci.yml/badge.svg)](https://github.com/JoahfromAlberta/gaslands_notebooklm_macro_package/actions)

This repository automates the integration between **UI.Vision Macros** and **NotebookLM**, using a lightweight RAG pipeline.  
It’s designed for commentary automation, ingestion, and retrieval during Gaslands sessions.

---

## 🚀 Features
- 📝 **Build prompts** with [`build_prompt.ps1`](uivision_macro/scripts/build_prompt.ps1)
- 📥 **Ingest data** into NotebookLM with [`ingest_run.py`](rag/ingest_run.py)
- 🔎 **Retrieve relevant context** with [`retrieve.py`](rag/retrieve.py)
- 🔄 **End-to-end automation** via [`test_all.bat`](uivision_macro/scripts/test_all.bat)
- ✅ Continuous Integration (CI) with GitHub Actions (Windows-based tests)

---

## ⚙️ Installation

Clone this repository and set up a virtual environment:

```powershell
git clone https://github.com/JoahfromAlberta/gaslands_notebooklm_macro_package.git
cd gaslands_notebooklm_macro_package

# Create + activate venv
python -m venv .venv
.\.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt


