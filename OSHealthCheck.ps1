Param(
    [Parameter(ParameterSetName='ServerList',
        Mandatory = $true,
        Position=0)]
        $srvlist)
        
$pipeline = {Out-GridView -Title "OS Health Check"}.GetSteppablePipeline()
$pipeline.Begin($true)


$servers = Get-Content $srvlist

Foreach ($s in $servers)
{
        $prejob = Try {
                    Invoke-Command -ComputerName $s -ErrorAction SilentlyContinue -AsJob -ScriptBlock {
                    $sfcfile = Test-Path C:\temp\sfc.txt
                    If ($sfcfile){Remove-Item C:\temp\sfc.txt -Force}
                    $wmifile = Test-Path C:\temp\wmi.txt
                    If ($wmifile){Remove-Item C:\temp\wmi.txt -Force}
                    $dismfile = Test-Path C:\temp\dism.txt
                    If ($dismfile){Remove-Item C:\temp\dism.txt -Force}
                    }
                    $line = [pscustomobject] @{"Name"=$s;"SFC Output"="Preparing to run";"WMI Output"="Preparing to run";"DISM Output"="Preparing to run"}
                    $pipeline.Process($line)}
                Catch {
                return "Could not connect to server"
                }

        If ($prejob.State -eq "Failed") {
            $line = [pscustomobject] @{"Name"=$s;"SFC Output"=$prejob;"WMI Output"=$prejob;"DISM Output"=$prejob}
            $pipeline.Process($line)
            exit}

        If ($prejob.State) {
        $line = [pscustomobject] @{"Name"=$s;"SFC Output"=$prejob.State;"WMI Output"=$prejob.State;"DISM Output"=$prejob.State}
        $pipeline.Process($line)}

        $sfcjob = Invoke-Command -ComputerName $s -ErrorAction SilentlyContinue -AsJob -ScriptBlock {                  
                    Start-Process sfc.exe -ArgumentList '/verifyonly' -Wait -NoNewWindow -RedirectStandardOutput C:\temp\sfc.txt}
     
        If ($sfcjob.State) {
        $line = [pscustomobject] @{"Name"=$s;"SFC Output"=$sfcjob.State;"WMI Output"="Scan not run yet";"DISM Output"="Scan not run yet"}
        $pipeline.Process($line)}
        Get-Job $sfcjob.Id | Wait-Job
        $sfc = Receive-Job $sfcjob.Id
                    
        $wmijob = Invoke-Command -ComputerName $s -ErrorAction SilentlyContinue -AsJob -ScriptBlock {
                    Start-Process winmgmt.exe -ArgumentList '/verifyrepository' -Wait -NoNewWindow -RedirectStandardOutput C:\temp\wmi.txt}                  
        If ($wmijob.State) {$line = [pscustomobject] @{"Name"=$s;"SFC Output"=$sfcjob.State;"WMI Output"=$wmijob.State;"DISM Output"="Scan not run yet"}
        $pipeline.Process($line)}
        Get-Job $wmijob.Id | Wait-Job
        $wmi = Receive-Job $wmijob.Id

        $dismjob = Invoke-Command -ComputerName $s -ErrorAction SilentlyContinue -AsJob -ScriptBlock {
                    Start-Process dism.exe -ArgumentList "/Online /Cleanup-Image /CheckHealth" -Wait -NoNewWindow -RedirectStandardOutput C:\temp\dism.txt}                   
        If ($dismjob.State) {$line = [pscustomobject] @{"Name"=$s;"SFC Output"=$sfcjob.State;"WMI Output"=$wmijob.State;"DISM Output"=$dismjob.State}
        $pipeline.Process($line)}
        Get-Job $dismjob.Id | Wait-Job
        $dism = Receive-Job $dismjob.Id

        $outjob = Invoke-Command -ComputerName $s -ErrorAction SilentlyContinue -AsJob -ScriptBlock {

                    $sfcout = $null
                    $wmiout = $null
                    $dismout = $null

                    $sfcfile = Test-Path C:\temp\sfc.txt
                    If ($sfcfile) {
                    $sfcout = Get-Content C:\temp\sfc.txt -Encoding Unicode
                    $sfcout = $sfcout.Trim() -ne "" | Select -Last 2
                    $sfcout = $sfcout | Out-String
                    }

                    $wmifile = Test-Path C:\temp\wmi.txt
                    If ($wmifile) {
                    $wmiout = Get-Content C:\temp\wmi.txt -Raw | Select -Last 2
                    }


                    $dismfile = Test-Path C:\temp\dism.txt
                    If ($dismfile) {
                    $dismout = Get-Content C:\temp\dism.txt
                    $dismout = ($dismout | Select -Last 2 | Out-String).TrimEnd()
                    }

                    [pscustomobject] @{"Name"=$using:s;"SFC Output"=$sfcout.ToString();"WMI Output"=$wmiout.ToString();"DISM Output"=$dismout.ToString()}
                    }
                    # | Select-Object -Property "Name","SFC OUtput","WMI Output","DISM Output"

        Get-Job $outjob.Id | Wait-Job
        $line = Receive-Job $outjob | Select Name,"SFC Output","WMI Output","DISM Output"
                    
                
    If ($line -ne $null){$pipeline.Process($line)}
}

$pipeline.End()