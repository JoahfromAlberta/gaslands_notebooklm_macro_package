<# ============================================================================
 build_prompt.ps1  — robust prompt builder
============================================================================ #>
$ErrorActionPreference = 'Stop'

# ---------- Resolve paths ----------
$ScriptDir = Split-Path -Parent $PSCommandPath
$UiMacro   = Resolve-Path (Join-Path $ScriptDir '..')
$Project   = Resolve-Path (Join-Path $UiMacro  '..')
$CfgPath   = Join-Path  $Project 'config.env'

$Comment   = Join-Path  $UiMacro  'comment.txt'
$Retrieved = Join-Path  $UiMacro  'retrieved_context.txt'
$OutPrompt = Join-Path  $UiMacro  'prompt.txt'

Write-Host "[build_prompt.ps1] ROOT   = $Project"
Write-Host "[build_prompt.ps1] UIMACRO= $UiMacro"

# ---------- Guard rails ----------
if (-not (Test-Path -LiteralPath $Comment)) {
  throw "[build_prompt.ps1] missing $Comment"
}
if (-not (Test-Path -LiteralPath $Retrieved)) {
  throw "[build_prompt.ps1] missing $Retrieved (run retrieve.bat first)"
}

# ---------- Optional config ----------
$NOTEBOOK_ID = $null
if (Test-Path -LiteralPath $CfgPath) {
  try {
    foreach ($line in Get-Content -LiteralPath $CfgPath -Encoding UTF8) {
      if ($line -match '^\s*NOTEBOOK_ID\s*=\s*(.+?)\s*$') {
        $NOTEBOOK_ID = $Matches[1].Trim()
        break
      }
    }
    if ($NOTEBOOK_ID) { Write-Host "[build_prompt.ps1] NOTEBOOK_ID=$NOTEBOOK_ID" }
  } catch {
    Write-Warning "[build_prompt.ps1] Could not parse ${CfgPath}: $($_.Exception.Message)"
  }
}

# ---------- Read inputs (UTF-8, raw) ----------
$commentTxt = Get-Content -LiteralPath $Comment   -Raw -Encoding UTF8
$contextTxt = Get-Content -LiteralPath $Retrieved -Raw -Encoding UTF8

# Bound context size (optional)
$MaxContextChars = 120000
if ($contextTxt.Length -gt $MaxContextChars) {
  Write-Warning "[build_prompt.ps1] retrieved_context.txt is large ($($contextTxt.Length) chars). Truncating to $MaxContextChars."
  $contextTxt = $contextTxt.Substring(0, $MaxContextChars) + "`n…[truncated]"
}

# ---------- Compose prompt ----------
$ts   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
$meta = if ($NOTEBOOK_ID) { "[meta] notebook_id=$NOTEBOOK_ID" } else { "" }

$prompt = @"
# NotebookLM Loop Prompt
$meta
[timestamp] $ts

## Context (top-k retrieval)
$contextTxt

## Task / User Turn Summary
$commentTxt
"@.Trim()

# ---------- Write prompt ----------
$prompt | Set-Content -LiteralPath $OutPrompt -Encoding UTF8
Write-Host "[build_prompt.ps1] Wrote $OutPrompt ($($prompt.Length) chars)"

# ---------- Clipboard (best effort with retry; do not hard-fail) ----------
$maxTries = 10
$copied   = $false
for ($i = 1; $i -le $maxTries; $i++) {
  try {
    Start-Sleep -Milliseconds 250
    Set-Clipboard -Value $prompt
    Start-Sleep -Milliseconds 150
    $echo = $null
    try { $echo = Get-Clipboard -Raw } catch { $echo = $null }
    if ($echo -and $echo.Length -ge [Math]::Min($prompt.Length, 16)) {
      Write-Host "[build_prompt.ps1] Clipboard set OK (try $i)"
      $copied = $true
      break
    } else {
      throw "Clipboard echo-back too short"
    }
  } catch {
    if ($i -eq $maxTries) {
      Write-Warning "[build_prompt.ps1] Clipboard busy after $maxTries tries; continuing without clipboard."
    }
    Start-Sleep -Milliseconds 300
  }
}

if ($copied) {
  Write-Host "[build_prompt.ps1] DONE -> file + clipboard"
} else {
  Write-Host "[build_prompt.ps1] DONE -> file only"
}
exit 0










