


#$global:dev = Get-Credential -Message "Please enter credentials for DEV domain" -Username "networkdev\amkmatte"
#$global:qut = Get-Credential -Message "Please enter credentials for QUT domain" -Username "networkqut\amkmatte"
#$global:prd = Get-Credential -Message "Please enter credentials for PRD domain" -Username "network\amkmatte"
#$global:sbx = Get-Credential -Message "Please enter credentials for SBX domain" -Username "networksbx\amkmatte"
#$global:trn = Get-Credential -Message "Please enter credentials for TRN domain" -Username "networktrn\amkmatte"
#$global:tst = Get-Credential -Message "Please enter credentials for TST domain" -Username "networktst\amkmatte"
#$global:pcp = Get-Credential -Message "Please enter credentials for PCP domain" -Username "networkpcp\amkmatte"

workflow Check-OS{

#    param (
#        [string[]] $ServerList,
#        [PSCredential] $credential
#    )

$servers = Get-Content $serverlist

Foreach -Parallel ($s in $servers){

#If ($s -like "*dev*"){$cred = $dev}
#If ($s -like "*qut*"){$cred = $qut}
#If ($s -like "*prd*"){$cred = $prd}
#If ($s -like "*sbx*"){$cred = $sbx}
#If ($s -like "*trn*"){$cred = $trn}
#If ($s -like "*tst*"){$cred = $tst}
#If ($s -like "*pcp*"){$cred = $pcp}
#Else {
#$cred = $prd
#}
$cred = $credential

$ositem = InlineScript{

Try {
$osstuff = (Get-WmiObject -ComputerName $using:s -Credential $using:mycred Win32_OperatingSystem -ErrorAction Stop -ErrorVariable badstuff).Name
$osname = $osstuff.Split("|")
return $osname[0]}
Catch {
$errmsg = $badstuff[0].Message
$parts = $errmsg.Split(":")
$smmsg = $parts[1].TrimStart(" ")
return $smmsg}

}

$def = InlineScript{
Try{
$defstuff = Get-WindowsFeature -ComputerName $using:s -Credential $using:mycred Windows-Defender -ErrorAction Stop -ErrorVariable badstuff
If ($defstuff.InstallState -eq "Installed"){return "Windows Defender is Installed"}
If ($defstuff.InstallState -eq "Available"){return "Windows Defender needs to be installed"}
}
Catch {
$errmsg = $badstuff[0].Message
$parts = $errmsg.Split(":")
$smmsg = $parts[1].TrimStart(" ")
return $smmsg}
}


$item = [PSCustomObject][Ordered]@{Name = $s; OperatingSystem = $ositem; DefenderFeature = $def}
$item | Export-CSV C:\users\amkmatte\desktop\trnoutput.csv -NoTypeInformation -Append
}
}


Check-OS


