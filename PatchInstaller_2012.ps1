# Run this script / ISE as administrator!
# Update these variables
$UpdatePath = "C:\Temp\Server2012R2"

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
