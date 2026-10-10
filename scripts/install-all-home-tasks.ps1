# Install one Windows Task Scheduler job that runs every portal locally.
# The job calls Git Bash + this repo's scripts. It does not start Cursor.
#
#   powershell -ExecutionPolicy Bypass -File scripts\install-all-home-tasks.ps1
#
# Optional:
#   -Time "09:00"   # local clock
param(
  [string]$Time = "09:00",
  [string]$TaskName = "LocalJobPortals-Daily"
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

function Find-GitBash {
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe",
    "C:\Program Files\Git\bin\bash.exe",
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
  )
  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return $c }
  }
  $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source -notmatch "WindowsApps|system32\\bash") {
    return $cmd.Source
  }
  return $null
}

$Bash = Find-GitBash
if (-not $Bash) {
  throw "Git Bash not found. Install Git for Windows, then re-run this script."
}

$Legacy = @(
  "HomeDaily-LinkedIn",
  "HomeDaily-Foundit",
  "HomeDaily-Cutshort",
  "HomeDaily-Naukri",
  "HomeDaily-Instahyre",
  "HomeDaily-Indeed",
  "HomeDaily-Hirist",
  "HomeDaily-HitechCity",
  "HomeDaily-Notification",
  "IndeedHomeDaily"
)
foreach ($name in $Legacy) {
  $existing = Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
  if ($existing) {
    Unregister-ScheduledTask -TaskName $name -Confirm:$false
    Write-Host "Removed legacy task $name"
  }
}

$Runner = Join-Path $Root "scripts\run-all-home-now.sh"
$Settings = New-ScheduledTaskSettingsSet `
  -AllowStartIfOnBatteries `
  -DontStopIfGoingOnBatteries `
  -StartWhenAvailable `
  -ExecutionTimeLimit (New-TimeSpan -Hours 8)
$Action = New-ScheduledTaskAction -Execute $Bash -Argument "`"$Runner`"" -WorkingDirectory "$Root"
$Trigger = New-ScheduledTaskTrigger -Daily -At $Time
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null

Write-Host "Installed $TaskName daily at $Time"
Write-Host "Repo: $Root"
Write-Host "Bash: $Bash"
Write-Host "Runner: $Runner"
Write-Host ""
Write-Host "The task runs scripts/run-all-home-now.sh (local Python/Node apply tools, then the status mail)."
Write-Host "It does not start the Cursor CLI and does not call the Cursor API."
Write-Host ""
Write-Host "Keep the PC awake at $Time and stay signed into each portal in Chrome."
Write-Host "Remove: Unregister-ScheduledTask -TaskName $TaskName -Confirm:`$false"
