# Install / switch Windows Task Scheduler to script-only daily applies (zero Cursor agent tokens).
#
#   powershell -ExecutionPolicy Bypass -File scripts\install-local-jobportals-scripts-task.ps1
#
# Options:
#   -Time "11:00"           Daily start (local clock)
#   -TaskName "..."         Scheduled task name
#   -DisableAgentTask       Disable LocalJobPortals-Daily (agent) if present
param(
  [string]$Time = "11:00",
  [string]$TaskName = "LocalJobPortals-Daily-Scripts",
  [switch]$DisableAgentTask
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

function Find-GitBash {
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe",
    "C:\Program Files\Git\bin\bash.exe",
    "$env:ProgramFiles\Git\bin\bash.exe"
  )
  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return $c }
  }
  throw "Git Bash not found. Install Git for Windows."
}

$Bash = Find-GitBash
$Script = Join-Path $Root "scripts\run-all-home-scripts.sh"
if (-not (Test-Path $Script)) {
  throw "Missing $Script"
}

$Action = New-ScheduledTaskAction -Execute $Bash -Argument "`"$Script`"" -WorkingDirectory "$Root"
$Trigger = New-ScheduledTaskTrigger -Daily -At $Time
$Settings = New-ScheduledTaskSettingsSet `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries `
  -StartWhenAvailable `
  -ExecutionTimeLimit (New-TimeSpan -Hours 12)

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null

Write-Host "Installed '$TaskName' daily at $Time"
Write-Host "  Repo:  $Root"
Write-Host "  Runs:  scripts/run-all-home-scripts.sh (no Cursor agent)"
Write-Host ""
Write-Host "Prereqs:"
Write-Host "  - Chrome logged into portals; git push to automation-results"
Write-Host "  - RESEND_API_KEY (user env) for status email"
Write-Host "  - Python (py -3) + Node for apply helpers"
Write-Host ""
Write-Host "Test now:"
Write-Host "  & `"$Bash`" `"$Script`""

if ($DisableAgentTask) {
  $agentNames = @("LocalJobPortals-Daily", "HomeDaily-LinkedIn", "HomeDaily-Foundit")
  foreach ($n in $agentNames) {
    $t = Get-ScheduledTask -TaskName $n -ErrorAction SilentlyContinue
    if ($t) {
      Disable-ScheduledTask -TaskName $n | Out-Null
      Write-Host "Disabled agent task: $n"
    }
  }
}

Write-Host ""
Write-Host "Agent path (tokens): scripts/run-all-home-now.sh"
Write-Host "Scripts path (no agent tokens): scripts/run-all-home-scripts.sh"
