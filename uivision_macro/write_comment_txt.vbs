' write_comment_txt.vbs
Option Explicit
Dim shell, cmd, target

target = "C:\projects\gaslands_notebooklm_macro_package\uivision_macro\comment.txt"

cmd = "powershell -NoProfile -Command ""Get-Clipboard -Raw | Set-Content -LiteralPath '" & target & "' -Encoding utf8"""
Set shell = CreateObject("WScript.Shell")
shell.Run cmd, 0, True

