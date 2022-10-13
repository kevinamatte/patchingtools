$collections = Get-Content C:\users\amkmatte\desktop\collections.txt

Foreach ($c in $collections){
$collname = (Get-CmDeviceCollection -CollectionId $c).Name
$members = Get-CmCollectionMember -CollectionId $c
Foreach ($m in $members){
$line = [PSCustomObject] @{"Name" = $m.Name; "Collection" = $collname}
$line | Export-CSV C:\users\amkmatte\desktop\output.csv -NoTypeInformation -Append}
}
