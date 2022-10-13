$servers = Get-Content C:\users\amkmatte\desktop\servers.txt
$cred = Get-Credential
$datatable = @()

Foreach ($s in $servers){
Write-Host "Creating job for" $s
Invoke-Command -ComputerName $s -Credential $cred -AsJob -JobName $s -HideComputerName -ScriptBlock {
            $patches = Get-Hotfix | Sort InstalledOn | Select HotfixId,InstalledBy,InstalledOn -Last 5
            Foreach ($p in $patches) {
                $str = $p.HotfixId + " " + $p.InstalledBy + " " + $p.InstalledOn
                If ($patchstr -ne $null){
                $patchstr = $patchstr + $str + "`n"}
                Else {$patchstr = $str + "`n"}
                }
            $reboot = & {if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
                       if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
                       if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
                       try { 
                       $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
                       $status = $util.DetermineIfRebootPending()
                       if(($status -ne $null) -and $status.RebootPending){
                           return $true
                       }
                       }
                       catch{}
                       return $false}
                       


            $outblock = [pscustomobject] @{
                "Name"=$env:ComputerName;
                "Last Patches"= $patchstr.Trim();
                "Last Boot Time"=(Get-CimInstance Win32_OperatingSystem | Select LastBootUpTime).LastBootUpTime;
                "Pending Reboot"=$reboot
                }
            $outblock
            } | Out-Null
}
Write-Host "Running jobs. Pausing for 5 seconds..."
Start-Sleep 5

Write-Host "Getting jobs"
$jobs = Get-Job

foreach ($j in $jobs) {
    if ($j.State -eq "Failed") {
        $data = [pscustomobject] @{
            "Name"=$j.Name;
            "Last Patches" = ($j.ChildJobs[0].JobStateInfo.Reason.Message);
            "Last Boot Time" = ""
            "Pending Reboot" = ""}
            $datatable += $data
            }
    else {
        if ($j.State -eq "Completed") {
        $data = Get-Job $j.Id | Receive-Job -ErrorAction SilentlyContinue
        $line = [pscustomobject] @{
            "Name"=$data.Name;
            "Last Patches"=$data."Last Patches";
            "Last Boot Time"=$data."Last Boot Time";
            "Pending Reboot"=$data."Pending Reboot"}
        $datatable += $line
    }
    Else {
        If ($j.State -eq "Running") {
        $data = [pscustomobject] @{
            "Name"=$j.Name;
            "Last Patches" = "Timed out waiting to connect";
            "Last Boot Time" = "";
            "Pending Reboot" = ""}
            $datatable += $data
        Get-Job $j.Id | Remove-Job -Force}
}
}
}

Get-Job | Remove-Job

$datatable | Out-GridView -Title "Check-Patch"