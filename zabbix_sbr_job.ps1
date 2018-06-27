# Script: zabbix_sbr_job
# Author original code: Romainsi
# Author russian edition: sergeeximius
# Description: Query Symantec job information
# 
# This script is intended for use with Zabbix > 3.X
#
# USAGE:
#   as a script:    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\scripts\zabbix_sbr_job.ps1" <ITEM_TO_QUERY> <JOBID>"
#   as an item:     sbr[<ITEM_TO_QUERY>,<JOBID>]
#
# Add to Zabbix Agent
#   UserParameter=sbr[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\scripts\zabbix_sbr_job.ps1" "$1" "$2"

$epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
$DateTZSeconds = (New-TimeSpan -Start "01/01/1970" -End $epoch).TotalSeconds

function ConvertTo-Encoding ([string]$From, [string]$To){  
    Begin{  
        $encFrom = [System.Text.Encoding]::GetEncoding($from)  
        $encTo = [System.Text.Encoding]::GetEncoding($to)  
    }  
    Process{  
        $bytes = $encTo.GetBytes($_)  
        $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)  
        $encTo.GetString($bytes)  
    }  
} 

Import-Module BEMCLI

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
  "DiscoverTasks" {
$apptasks = Get-BEJob -Jobtype Backup -Status Active
if (!$apptasks) {$apptasks = Get-BEJob -Jobtype Backup -Status Scheduled}
$apptasksok = $apptasks.Name | ConvertTo-Encoding cp866 utf-8
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($currentapptasks in $apptasksok)
{
    if ($idx -lt $apptasksok.count)
    {
     
        $line= "{ `"{#SYMANTECBACKUP}`" : `"" + $currentapptasks + "`" },"
        write-host $line
    }
    elseif ($idx -ge $apptasksok.count)
    {
    $line= "{ `"{#SYMANTECBACKUP}`" : `"" + $currentapptasks + "`" }"
    write-host $line
    }
    $idx++;
} 
write-host
write-host " ]"
write-host "}"}}


switch ($ITEM) {
  "TaskLastResult" {
[string] $name = $ID
$nametask = Get-BEJobHistory -Name "$name" -JobType "Backup"| Select -last 1
$nametask1 = $nametask.JobStatus
$nametask2 = "$nametask1".replace('Error','0').replace('Warning','1').replace('Succeeded','2').replace('None','2').replace('idle','3').replace('Canceled','4').replace('Recovered','5') | ConvertTo-Encoding cp866 utf-8 
Write-Output ($nametask2)
}}

switch ($ITEM) {
  "TaskLastRunTime" {
[string] $name = $ID
$nametask = Get-BEJobHistory -Name "$name" -JobType "Backup"| Select -last 1
$taskResult = $nametask.StartTime
$date = get-date -date "01/01/1970"
$taskResult1 = (New-TimeSpan -Start $date -end $taskresult).TotalSeconds - $DateTZSeconds
Write-Output ($taskResult1)
}}

switch ($ITEM) {
  "TaskEndRunTime" {
[string] $name = $ID
$nametask = Get-BEJobHistory -Name "$name" -JobType "Backup"| Select -last 1
$taskResult = $nametask.EndTime
$date = get-date -date "01/01/1970"
$taskResult1 = (New-TimeSpan -Start $date -end $taskresult).TotalSeconds - $DateTZSeconds
Write-Output ($taskResult1)
}}

switch ($ITEM) {
  "TaskType" {
[string] $name = $ID
$nametask = Get-BEJob -Name "$name"
$nametask1 = $nametask.Storage.StorageType
Write-Output ($nametask1)
}}

switch ($ITEM) {
  "TaskLastTotalDataSize" {
[string] $name = $ID
$nametask = (Get-BEJobHistory -Name "$name" -JobType "Backup"| Select -last 1).TotalDataSizebytes
Write-Output ($nametask)
}}

switch ($ITEM) {
  "TestEncoding" {
[string] $name = $ID
Write-Output ($name) | ConvertTo-Encoding cp866 utf-8
Write-Output ($name)
}}
