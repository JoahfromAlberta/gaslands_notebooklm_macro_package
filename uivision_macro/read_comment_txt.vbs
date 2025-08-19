' read_comment_txt.vbs
Option Explicit
Dim fso, file, text, html

On Error Resume Next

Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists("comment.txt") Then
  Set file = fso.CreateTextFile("comment.txt", True)
  file.Write ""
  file.Close
End If

Set file = fso.OpenTextFile("comment.txt", 1, False)
text = file.ReadAll
file.Close

Set html = CreateObject("htmlfile")
html.ParentWindow.ClipboardData.SetData "text", text

