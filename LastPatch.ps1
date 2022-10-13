$servers = Get-Content C:\users\amkmatte\desktop\day2.txt
$csv = New-Item C:\users\amkmatte\desktop\day2.csv -Force

$prd = Get-Credential -UserName network\amkmatte -Message "Prod Creds"
$dev = Get-Credential -UserName networkdev\amkmatte -Message "Dev Creds"
$qut = Get-Credential -UserName networkqut\amkmatte -Message "Qut Creds"
$pcp = Get-Credential -UserName networkpcp\amkmatte -Message "PCP Creds"
$sbx = Get-Credential -UserName networksbx\amkmatte -Message "SBX Creds"
$trn = Get-Credential -UserName networktrn\amkmatte -Message "TRN Creds"

Foreach ($s in $servers){
    $badthing = $null
    $err = $null
    $srv = ($s.Split("-"))[0]
    $domain = ($s.Split("-"))[1]
    If ($domain -eq "NETWORK") {$cred = $prdcred}
    If ($domain -eq "NETWORKDEV") {$cred = $devcred}
    If ($domain -eq "NETWORKQUT") {$cred = $qutcred}
    If ($domain -eq "NETWORKPCP") {$cred = $pcpcred}
    If ($domain -eq "NETWORKSBX") {$cred = $sbxcred}
    If ($domain -eq "NETWORKTRN") {$cred = $trncred}
    If ($domain -eq "WORKGROUP") {$cred = $prdcred}
    Write-Host "Working on $srv"
    $patch = Invoke-Command -ComputerName $srv -Credential $cred -ScriptBlock {Get-Hotfix | Sort InstalledOn | Select-Object -Last 1} -ErrorAction SilentlyContinue -ErrorVariable badthing
    If ($badthing) {$err = $badthing.ErrorDetails}
    $obj = [pscustomobject] @{
            "Server Name" = $srv
            "Last Patched" = $patch.InstalledOn
            "Error Message" = $err}
    Write-Host $obj
    $obj | Export-CSV C:\users\amkmatte\desktop\day2.csv -NoTypeInformation -Append -Force}