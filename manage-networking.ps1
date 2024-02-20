
Get-AzSubscription

$sub=vsentont
$rgName=hubvnet-fw
$location=canadacentral
$hubVNetName=vnet-hub
$prodVnetName=vnet-prod-$sub
$devVnetName=vnet-dev-$sub
$onpremVnetName=vnet-onprem-$sub
$azFirewallName=AzFW01
$pip-fw-Name=pip-firewall

$azfw = Get-AzFirewall -Name $azFirewallName -ResourceGroupName $rgName
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

$azfw = Get-AzFirewall -Name "FW Name" -ResourceGroupName "RG Name"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "RG Name" -Name "VNet Name"
$publicip1 = Get-AzPublicIpAddress -Name "Public IP1 Name" -ResourceGroupName "RG Name"
$publicip2 = Get-AzPublicIpAddress -Name "Public IP2 Name" -ResourceGroupName "RG Name"
$azfw.Allocate($vnet,@($publicip1,$publicip2))