$OS = (Get-WmiObject Win32_OperatingSystem).Name

New-PSDrive -Name updates -PSProvider FileSystem -Root "\\file026.network.lan\IT_OPERATIONS\2022 Patching\May 2022\Manual Patches"
New-Item -Path 'C:\temp\updates' -ItemType Directory -Force
If ($OS -like "*2012*"){
    Copy-Item updates:\Server2012R2\* C:\temp\updates\ -Recurse -Force}
If ($OS -like "*2016*"){
    Copy-Item updates:\Server2016\* C:\temp\updates\ -Recurse -Force}
If ($OS -like "*2019*"){
    Copy-Item updates:\Server2019\* C:\temp\updates\ -Recurse -Force}

Remove-PSDrive -Name updates

$UpdatePath = "C:\temp\updates"

# Get all updates
$Updates = Get-ChildItem -Path $UpdatePath -Recurse | Where-Object {$_.Name -like "*msu*"}

# Iterate through each update
ForEach ($update in $Updates) {

    # Get the full file path to the update
    $UpdateFilePath = $update.FullName

    # Logging
    write-host "Installing update $($update.BaseName)"

    # Install update - use start-process -wait so it doesnt launch the next installation until its done
    Start-Process -wait wusa -ArgumentList "$UpdateFilePath /quiet /norestart"
}

Remove-Item C:\temp\updates -Recurse -Force
Restart-Service ccmexec
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000108}"

