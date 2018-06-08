<#

 The script creates a scheduled task to run powershell script periodically.

#>

$ScriptPath = "C:\Scripts\Powershell"

$SchedTaskPath = "\UCL"
$SchedTaskName = "Change this for task name"
$SchedTaskDesc = "Change this for a decent description of what the task does"

$cred = Get-Credential -Message "Enter credentials to run service as (USE A SERVICE ACCOUNT!!)"

$SchedUser = $cred.UserName
$SchedPass = $cred.GetNetworkCredential().Password    # Get the actual password string

$action    = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-ExecutionPolicy Bypass C:\put\full\path\to\the\script\here'

$trigger   = New-ScheduledTaskTrigger -Daily -At 9am

try {
    $schedtask = Register-ScheduledTask -RunLevel Highest `
    -User $SchedUser `
    -Password $SchedPass `
    -TaskPath $SchedTaskPath `
    -Action $action `
    -Trigger $trigger `
    -TaskName $SchedTaskName `
    -Description $SchedTaskDesc `
    -ErrorAction Stop
}
catch {
    Write-Host -BackgroundColor Red -ForegroundColor Yellow -NoNewline "Could not register scheduled task $SchedTaskName :"
    Write-Host -ForegroundColor Yellow " $_"
    exit 1
}

# If we are here then the task registered succesfully
# I need to attribute the person i took this from ...
$schedtask.Triggers.Repetition.Duration = "P1D"   # -- Repeat for a duration of one day
$schedtask.Triggers.Repetition.Interval = "PT30M" # -- Repeat every 30 minutes, 
                                                  # -- use PT1H for every hour

$schedtask | Set-ScheduledTask -User $SchedUser -Password $SchedPass
