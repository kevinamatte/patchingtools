#Write-Host "Loading VMWare PowerCli Module. Please be patient"
#Import-Module VMWare.PowerCli > $null
#Write-Host "Loading Azure PowerShell Module. Please be patient"
#Import-Module Az > $null
#Write-Host "Importing Inventory list"
$winlist = Import-CSV D:\kmatte\Inventory\winlist.csv

$cred = Get-Credential -Message "Credential for vCenter and Azure administration (in the format of am<user>@network.lan:)"

$srv = Read-Host -Prompt "Which server are you looking to reboot?"

$srvinfo = $winlist | Where 'Server Name' -eq $srv | Select 'Server Name','Console Name'
$srvname = $srvinfo.'Server Name'

If ($srvinfo.'Console Name' -like "*/ui") {
    $con = $srvinfo.'Console Name'.ToString()
    $con = $con.TrimStart('https://')
    $con = $con.TrimEnd('/ui')
    Connect-VIServer -Server $con -Credential $cred > $null
    $vminfo = Get-VM | Where Name -like "*$srvname*"
    Write-Host "Found:" $vminfo.Name "on" $con -ForegroundColor Green
    Restart-VM $vminfo.Name -Confirm}

If ($srvinfo.'Console Name' -eq "Microsoft Azure"){
Connect-AzAccount -Credential $cred
#search in dev subscription
Set-AzContext -Subscription d54f5885-394a-4860-84b9-d3c6dc20f130
$vm = Get-AzVM -Name $srvinfo.'Server Name'
#if not in dev, look in prd
If (!$vm) {Set-AzContext -Subscription 5275bbe1-ea9f-4fca-a8ef-4ef79d5e5a0b
$vm = Get-AzVM -Name $srvinfo.'Server Name'}
#if not in prd, look in qut
If (!$vm) {Set-AzContext -Subscription f5e8287c-fbf0-4137-825a-f19abf52ac8e
$vm = Get-AzVM -Name $srvinfo.'Server Name'}
#if not in qut, look in sbx
If (!$vm) {Set-AzContext -Subscription 25b76ccd-57cc-46a4-9bdc-91ba167a1afe
$vm = Get-AzVM -Name $srvinfo.'Server Name'}

Restart-AzVM -Name $vm.Name -Confirm}

Else {Write-Host "Server not found in VMWare or Azure"}







