$Date = Get-Date -f "yyyy-MM-dd"
$Time = Get-Date -f "HH-mm-ss"

$Computers = Get-Content -Path "C:\servers.txt"
$Computers >C:\Temp\servers_"$Date"_"$Time".txt
$ErrorActionPreference = "SilentlyContinue"
$Report = @()
foreach ($Computer in $Computers)
{
    if (test-connection $Computer -quiet -count 1)
    {   
        
    
        #Computer is online
        $path = "\\" + $Computer + "\c$\Windows\System32\Tasks"
        $tasks = Get-ChildItem -recurse -Path $path -File
        foreach ($task in $tasks)
        {
            $Info = Get-ScheduledTask -CimSession $Computer -TaskName $task | Get-ScheduledTaskInfo | Select LastRunTime, LastTaskResult
    
            $Details = "" | select ComputerName, Task, User, Enabled, Application, LastRunTime, LastTaskResult
            $AbsolutePath = $task.directory.fullname + "\" + $task.Name
            $TaskInfo = [xml](Get-Content $AbsolutePath)
            $Details.ComputerName = $Computer
            $Details.Task = $task.name
            $Details.User = $TaskInfo.task.principals.principal.userid
            $Details.Enabled = $TaskInfo.task.settings.enabled
            $Details.Application = $TaskInfo.task.actions.exec.command 
            $Details.LastRunTime = $Info.LastRunTime
            $Details.LastTaskResult = $Info.LastTaskResult
            #$Details
            Write-Host "working on $task.name please wait..........." -ForegroundColor Green
            $Report += $Details
        }
    }
    else
    {
        #Computer is offline
    }
}
$Report | Export-csv C:\Temp\Tasks_"$Date"_"$Time".csv -NoTypeInformation

#$Report | Format-Table -AutoSize