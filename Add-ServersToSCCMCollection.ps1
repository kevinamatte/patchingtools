$ServerList = Read-Host -Prompt "Enter path to list of server names"
$CollectionId = Read-Host -Prompt "Enter the Collection ID to add the servers to"
$servers = Get-Content $ServerList

Foreach ($s in $servers){
    $i = Get-CMDevice -Name $s
    Add-CMDeviceCollectionDirectMembershipRule -CollectionId $CollectionId -ResourceId $i.Id}