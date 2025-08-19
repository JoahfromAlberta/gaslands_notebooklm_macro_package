
📦 Gaslands AI Assistant + NotebookLM Commentary Automation

🔧 Folder: `uivision_macro/`

✅ HOW TO INSTALL:

1. Install UI.Vision RPA browser extension (Chrome/Firefox)
   - https://ui.vision

2. Import the macro:
   - Open UI.Vision > Macros > Import > Select `NotebookLM_Commentary.json`

3. Place `read_comment_txt.vbs` and `write_comment_txt.vbs` in same folder as your `comment.txt`

4. Ensure NotebookLM is open in Tab 2 of your browser

5. Press play on the macro. It will:
   - Read `comment.txt`
   - Paste it into NotebookLM
   - Wait for reply
   - Copy the reply
   - Overwrite `comment.txt`

6. Flask app (`app.py`) will show updated commentary live.

⚠️ Requires XModule to be installed and enabled (for clipboard + file I/O).
Get it here: https://ui.vision/download
