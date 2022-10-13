param ( [Parameter(Mandatory=$true)] $Domain, [Parameter(Mandatory=$true)] $ServerList )

$cred = Get-Credential -Message "Please enter credentials for your selected domain"
$psdrivecred = Get-Credential -Message "Please enter credentials for the client location"
$shortservers = Get-Content $ServerList
$servers = $shortservers.Foreach({$_+"."+$Domain})

Foreach ($s in $servers){

Write-Host "Working on" $s
Invoke-Command -ComputerName $s -Credential $cred -ScriptBlock{
        New-PSDrive -Name SCCM -PSProvider FileSystem -Root "\\MGTPRDCGY020.network.lan\kmatte\" -Credential $using:psdrivecred
        Copy-Item SCCM:\Client\ C:\temp\ -Recurse
        Start-Process C:\temp\client\ccmsetup.exe -ArgumentList "/mp:SCCMPRDCGY120.network.lan SMSSITECODE=P01 /forceinstall" -Wait
}
Write-Host "Finished install on" $s
}

Foreach ($s in $servers){
    $ccmsetup = Invoke-Command -ComputerName $s -Credential $cred -Scriptblock {Get-Process ccmsetup} -ErrorAction SilentlyContinue
    If ($ccmsetup -eq $null){Write-Host "CCMSETUP is still running on" $s}
    Else {Write-Host "CCMSETUP has finished on" $s}
    } 
