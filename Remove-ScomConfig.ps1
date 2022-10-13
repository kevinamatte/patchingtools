param ( [Parameter(Mandatory=$true)] $ComputerName )

$cred = Get-Credential -Message "Enter your credentials for the computer"

Invoke-Command -ComputerName $ComputerName -Credential $cred -ScriptBlock {
    $mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma.GetManagementGroups()
    $mma.RemoveManagementGroup("SUNCOR-PRD-MG01")
    $mma.ReloadConfiguration()
    $mma.GetManagementGroups()
    }