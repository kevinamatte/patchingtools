Foreach ($n in (Get-Content C:\users\amkmatte\desktop\servers.txt)){$Collections = (Get-WmiObject -ComputerName sccmprdcgy120.network.lan  -Namespace root/SMS/site_P01 -Query "SELECT SMS_Collection.* FROM SMS_FullCollectionMembership, SMS_Collection where name = '$n' and SMS_FullCollectionMembership.CollectionID = SMS_Collection.CollectionID").Name
$patchcoll = $collections -like "SRV - Day*" | Sort
Write-Host $n -ForegroundColor Yellow
Write-Host ($patchcoll -join "`n")
}