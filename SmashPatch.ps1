$servers = Get-Content C:\users\amkmatte\desktop\servers.txt
$prdcred = Get-Credential -UserName 'network\amkmatte' -Message 'Prd Creds'
$devcred = Get-Credential -UserName 'networkdev\amkmatte' -Message 'Dev Creds'
$qutcred = Get-Credential -UserName 'networkqut\amkmatte' -Message 'Qut Creds'
$sbxcred = Get-Credential -UserName 'networksbx\amkmatte' -Message 'Sbx Creds'

workflow SmashPatch {

Param(
    [Parameter(Mandatory = $true)] $srvlist, [Parameter(Mandatory = $false)] $prd, [Parameter(Mandatory = $false)] $dev, [Parameter(Mandatory = $false)] $qut, [Parameter(Mandatory = $false)] $sbx
)

Foreach -Parallel ($s in $srvlist){
InlineScript {
If ($using:s -like "*prd*") {$cred = $using:prd}
If ($using:s -like "*dev*") {$cred = $using:dev}
If ($using:s -like "*qut*") {$cred = $using:qut}
If ($using:s -like "*sbx*") {$cred = $using:sbx}
If ($using:s -like "*trn*") {$cred = $using:dev}
Invoke-Command -ComputerName $using:s -Credential $cred -ScriptBlock {
    $patches = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where-Object { ($_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*")}
    Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $patches) -Namespace root\ccm\clientsdk
    Start-Sleep -Seconds 240
    Wait-Process -Name "wuauclt"
    Restart-Computer -Force
    }
}
}
}

SmashPatch -srvlist $servers -prd $prdcred -dev $devcred -qut $qutcred -sbx $sbxcred
