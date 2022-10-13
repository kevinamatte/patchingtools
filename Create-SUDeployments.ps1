$collections = "P010192E", "P01008EB", "P010089B", "P010089C", "P010089D", "P010089E", "P010089F", "P0100D9F", "P010089A", "P01008B8", "P01008B7", "P01008A6", "P01008A5", "P01008AA", "P01008AB", "P01008A9", "P01008BB", "P01008BC", "P01008BE", "P01008C2", "P01008C0", "P01008C1", "P01008BF", "P01008C7", "P01008C8", "P01008C9", "P01008C4", "P01008C5", "P01008C6", "P01008CB", "P01008CE", "P01008CC", "P01008CF", "P01008D0", "P01008CD", "P01008DA", "P01008D3", "P01008D5", "P01008D6", "P01008D7", "P01008D8", "P01008D2", "P01008D4", "P01008DB", "P01008D9", "P01008B0", "P01008B1", "P01008AE", "P01008AF", "P01008AD", "P01008B3", "P01008ED", "P0100D9E", "P01008EE", "P01008A3", "P01008A1", "P01008A2", "P01008A0", "P01008E2", "P01008DF", "P01008E0", "P01008DD", "P01008DE", "P01008E1", "P01008E4", "P01008E7", "P01008E8", "P01008E5", "P01008E6"

Foreach ($c in $collections)
{
$coll = Get-CmCollection -CollectionId $c
$name = ($coll.name)+" - Feb 2022"
New-CMSoftwareUpdateDeployment -DeploymentName $name -SoftwareUpdateGroupName "February 2022 Server Patches" -CollectionId $c -DeploymentType Required -VerbosityLevel AllMessages -AvailableDateTime (Get-Date) -DeadlineDateTime "2032/01/01 01:00AM" -UserNotification DisplaySoftwareCenterOnly -SoftwareInstallation $false -RestartServer $false -RequirePostRebootFullScan $True -ProtectedType RemoteDistributionPoint -DisableOperationsManagerAlert $true
}

