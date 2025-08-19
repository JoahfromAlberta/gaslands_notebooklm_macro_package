Option Explicit

Dim fso, uiDir, outPath, text, ok
Set fso = CreateObject("Scripting.FileSystemObject")

' uiDir = this file's folder
uiDir = fso.GetParentFolderName(WScript.ScriptFullName)
outPath = fso.BuildPath(uiDir, "last_reply.txt")

text = ""
ok = False

' Try MSForms first (best)
On Error Resume Next
Dim dataObj
Set dataObj = CreateObject("MSForms.DataObject")
If Err.Number = 0 Then
  dataObj.GetFromClipboard
  text = dataObj.GetText()
  ok = True
End If
On Error GoTo 0

' Fallback: HTMLFile technique
If Not ok Then
  On Error Resume Next
  Dim html
  Set html = CreateObject("htmlfile")
  text = html.ParentWindow.ClipboardData.GetData("Text")
  If Err.Number = 0 Then ok = True
  On Error GoTo 0
End If

If Not ok Then
  WScript.Echo "write_last_reply_txt.vbs: Could not read clipboard."
  WScript.Quit 1
End If

Dim ts
Set ts = fso.OpenTextFile(outPath, 2, True, -1) ' ForWriting, Create, Unicode(-1=UTF-16LE)
ts.Write text
ts.Close

WScript.Echo "write_last_reply_txt.vbs OK -> " & outPath
WScript.Quit 0

