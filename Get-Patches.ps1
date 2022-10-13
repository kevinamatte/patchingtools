
$servers = Get-Content C:\users\amkmatte\desktop\patch.txt
$csv = New-Item C:\users\amkmatte\desktop\LastPatches.csv -Force
Set-Content $csv '"Server Name","Last KB Installed","Installation Date"'

$prd = Get-Credential -Message "Creds for PRD Environment" -Username "network\amkmatte"
$dev = Get-Credential -Message "Creds for DEV Environment" -Username "networkdev\amkmatte"
$qut = Get-Credential -Message "Creds for QUT Environment" -Username "networkqut\amkmatte"
$sbx = Get-Credential -Message "Creds for SBX Environment" -Username "networksbx\amkmatte"
$trn = Get-Credential -Message "Creds for TRN Environment" -Username "networktrn\amkmatte"
$tst = Get-Credential -Message "Creds for TST Environment" -Username "networktst\amkmatte"
$pcp = Get-Credential -Message "Creds for PCP Environment" -Username "networkpcp\amkmatte"

Foreach ($s in $servers){

If ($s -like "*dev*"){$cred = $dev}
If ($s -like "*qut*"){$cred = $qut}
If ($s -like "*prd*"){$cred = $prd}
If ($s -like "*sbx*"){$cred = $sbx}
If ($s -like "*trn*"){$cred = $trn}
If ($s -like "*tst*"){$cred = $tst}
If ($s -like "*pcp*"){$cred = $pcp}

$lastupdate = $null

$updates = Invoke-Command -ComputerName $s -Credential $cred -ScriptBlock {Get-Hotfix | Sort InstalledOn}

$count = $updates.count
$count = ($count - 1)

$lastupdate = $updates[$count]

$output = New-Object -TypeName PSCustomObject -Property @{"Server Name" = $s; "Last KB Installed" = $lastupdate.HotFixId; "Installation Date" = $lastupdate.InstalledOn}

$output | Export-Csv $csv -Append -NoTypeInformation}






