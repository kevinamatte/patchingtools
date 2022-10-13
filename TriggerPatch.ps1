$servers = Get-Content C:\users\amkmatte\desktop\servers.txt
$prdcred = Get-Credential -UserName 'network\amkmatte' -Message 'Prd Creds'
$devcred = Get-Credential -UserName 'networkdev\amkmatte' -Message 'Dev Creds'
$qutcred = Get-Credential -UserName 'networkqut\amkmatte' -Message 'Qut Creds'
$sbxcred = Get-Cred

Foreach ($s in $servers){
If ($s -like "*prd*") {$cred = $prdcred}
If ($s -like "*dev*") {$cred = $devcred}
If ($s -like "*qut*") {$cred = $qutcred}
If ($s -like "*sbx*") {$cred = $sbxcred}
Invoke-WMIMethod -ComputerName $s -Credential $cred -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000108}"
}



$servers.Foreach({Invoke-WMIMethod -ComputerName $_ -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000108}"})
