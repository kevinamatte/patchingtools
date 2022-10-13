$outarray = @()

$logfiles = Get-ChildItem "\\network.lan\support\Apps\SCCM\ClientHealth\Logs\"

Foreach ($l in $logfiles){

$log = Get-Content $l.FullName

$hostname = ($log | Select-String -Pattern "Hostname: " | Out-String).Remove(0,12)
$os = ($log | Select-String -Pattern "Operatingsystem: " | Out-String).Remove(0,19)
$updates = ($log | Select-String -Pattern "OSUpdates: " | Out-String).Remove(0,13)
$domain = ($log | Select-String -Pattern "Domain: " | Out-String).Remove(0,10)
$reboot = ($log | Select-String -Pattern "PendingReboot: " | Out-String).Remove(0,17)
$boottime = ($log | Select-String -Pattern "LastBootTime: " | Out-String).Remove(0,16)
$adminshare = ($log | Select-String -Pattern "AdminShare: " | Out-String).Remove(0,14)
$statemessages = ($log | Select-String -Pattern "StateMessages: " | Out-String).Remove(0,17)
$wuahandler = ($log | Select-String -Pattern "WUAHandler: " | Out-String).Remove(0,14)
$wmi = ($log | Select-String -Pattern "WMI: " | Out-String).Remove(0,7)
$compstate = ($log | Select-String -Pattern "RefreshComplianceState: " | Out-String).Remove(0,26)
$clientver = ($log | Select-String -Pattern "Version: " | Out-String).Remove(0,17)
$clienttime = ($log | Select-String -Pattern "Timestamp: " | Out-String).Remove(0,13)
$swmeter = ($log | Select-String -Pattern "SWMetering: " | Out-String).Remove(0,14)
$bits = ($log | Select-String -Pattern "BITS: " | Out-String).Remove(0,8)
$clientsettings = ($log | Select-String -Pattern "ClientSettings: " | Out-String).Remove(0,18)
$patchlevel = ($log | Select-String -Pattern "PatchLevel: " | Out-String).Remove(0,14)


$lineentry = [pscustomobject] @{
    "Hostname" = $hostname;
    "Log File Date" = $l.CreationTime
    "Operating System" = $os;
    "Patches Last Installed" = $updates;
    "Domain" = $domain;
    "Pending Reboot" = $reboot;
    "Last Boot Time" = $boottime;
    "Admin Share Available" = $adminshare;
    "State Messages" = $statemessages;
    "WUAHandler" = $wuahandler;
    "WMI" = $wmi;
    "Last Compliance State Refresh" = $compstate;
    "Client Version" = $clientver;
    "Client Timestamp" = $clienttime;
    "Software Metering" = $swmeter;
    "BITS" = $bits;
    "Client Settings" = $clientsettings;
    "Patch Level" = $patchlevel}

$outarray += $lineentry
}

$outarray | Export-Csv C:\users\amkmatte\desktop\logparse.csv -NoTypeInformation

