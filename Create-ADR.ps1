$collections = Get-Content C:\users\amkmatte\desktop\collections.txt

Foreach ($s in $collections){

$numbers = $s -replace "[^0-9]", ''
$day = $numbers.Substring(0,2)
$rawtime = $numbers.Substring($numbers.length-4)
$time = $rawtime.Insert(2,':')

If (($day -eq "02") -or ($day -eq "03") -or ($day -eq "04") -or ($day -eq "05") -or ($day -eq "06")){$weekorder = "Second"}
If (($day -eq "07") -or ($day -eq "08") -or ($day -eq "09") -or ($day -eq "10") -or ($day -eq "11") -or ($day -eq "12") -or ($day -eq "13")){$weekorder = "Third"}
If (($day -eq "14") -or ($day -eq "15")){$weekorder = "Fourth"}
If (($day -eq "07") -or ($day -eq "14")){$dayofweek = "Tuesday"}
If (($day -eq "08") -or ($day -eq "15")){$dayofweek = "Wednesday"}
If (($day -eq "02") -or ($day -eq "09")){$dayofweek = "Thursday"}
If ($day -eq "10"){$dayofweek = "Friday"}
If (($day -eq "04") -or ($day -eq "11")){$dayofweek = "Saturday"}
If (($day -eq "05") -or ($day -eq "12")){$dayofweek = "Sunday"}
If (($day -eq "06") -or ($day -eq "13")){$dayofweek = "Monday"}


$Products = "Windows Server 2012 R2","Windows Server 2016","Windows Server 2019"
$UpdateClassifications = "Critical Updates","Security Updates","Update Rollups","Updates"
$Severity = "Critical","Important","Moderate"
  

$Schedule = New-CMSchedule -DayOfWeek $dayofweek -WeekOrder $weekorder -Start ([Datetime]$time)

New-CMSoftwareUpdateAutoDeploymentRule `
    -CollectionName $s `
    -DeploymentPackageName "February 2022 Server Patches" `
    -Name $s `
    -Product $Products `
    -RunType RunTheRuleOnSchedule `
    -Schedule $Schedule `
    -Severity $Severity `
    -UpdateClassification $UpdateClassifications `
    -AddToExistingSoftwareUpdateGroup $true `
    -AllowRestart $True `
    -AllowSoftwareInstallationOutsideMaintenanceWindow $True `
    -AllowUseMeteredNetwork $True `
    -AvailableImmediately $true `
    -DateReleasedOrRevised Last1month `
    -DeadlineImmediately $True `
    -DisableOperationManager $True `
    -EnabledAfterCreate $true `
    -Language "English" `
    -LanguageSelection "English" `
    -UserNotification DisplayAll `
    -UseUtc $false `
    -SuppressRestartServer $false `
}
