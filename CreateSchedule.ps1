<#

 The script creates a scheduled task to run powershell script periodically.

#>

$ScriptPath = "C:\Scripts\Powershell\TSM"
$SchedUser  = ""
$SchedPass  = ""
$SchedTaskPath = "\UCL"
$SchedTaskName = "TSMVE DM Service Check"
$SchedTaskDesc = "Check the TSMVE DataMovers for stuck Scheduler services"

$cred = Get-Credential -Message "Enter credentials to run service as (USE A SERVICE ACCOUNT!!)"

$SchedUser = $cred.UserName
$SchedPass = $cred.GetNetworkCredential().Password    # Get the actual password string

$action    = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-ExecutionPolicy Bypass C:\Scripts\Powershell\TSM\RestartScheduler.ps1'

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
$schedtask.Triggers.Repetition.Duration = "P1D"   #//Repeat for a duration of one day
$schedtask.Triggers.Repetition.Interval = "PT30M" #//Repeat every 30 minutes, use PT1H for every hour
$schedtask | Set-ScheduledTask -User $SchedUser -Password $SchedPass
