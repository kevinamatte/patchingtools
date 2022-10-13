Foreach ($s in $servers){
$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $s -Credential $cred | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $s -Credential $cred

}


Invoke-Command -ComputerName $s -Credential $cred -ScriptBlock {
       $SMSCli = [wmiclass] "\\$using:s\root\ccm:SMS_Client"
       If ($SMSCli){
       $SMSCli.RequestMachinePolicy()
       $SMSCli.EvaluateMachinePolicy()}}
}



$s = "BKDPRDTOR001"

Foreach ($s in $servers){
Write-Host "Working on" $s
$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $s -Credential $cred| Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $s -Credential $cred}


Foreach ($s in $servers){
$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $s | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk -ComputerName $s}


Foreach ($s in $servers){
$updates = Invoke-Command -ComputerName $s -ScriptBlock {Get-Process -Name wuauclt -ErrorAction SilentlyContinue}
If ($updates){Write-Host "Updates running on" $s}
Else {Write-Host "Updates finished on" $s}}


Foreach ($s in $servers){
$updates = Invoke-Command -ComputerName $s -Credential $cred -ScriptBlock {Get-Process -Name wuauclt -ErrorAction SilentlyContinue}
If ($updates){Write-Host "Updates running on" $s}
Else {Write-Host "Updates finished on" $s}}




Discovery Script –



$cmClientUserSettings = [WmiClass]”\\.\ROOT\ccm\ClientSDK:CCM_ClientUXSettings”
$nonbusinessHours = $cmClientUserSettings.GetAutoInstallRequiredSoftwaretoNonBusinessHours()
Return $nonbusinessHours.AutomaticallyInstallSoftware





Remediation Script –



Invoke-WmiMethod -Namespace “Root\ccm\ClientSDK” -Class CCM_ClientUXSettings -Name SetAutoInstallRequiredSoftwaretoNonBusinessHours -ArgumentList @($TRUE)