$AzResourceGroupName = "RGWestEurope"
$VirtualNetworkName = "$($AzResourceGroupName)vNet"
$PublicIpAddrName = "$($AzResourceGroupName)PubIp"
$vmADName = "WINAD01"
$vmMGMTName = "WINMGMT01"
$vmWIN10Name = "WIN1001"
$adminUsername = "secmaster"
$Secure_String_Pwd = ConvertTo-SecureString "P@ssword123!@#" -AsPlainText -Force
$PubIpMyComp = (Invoke-RestMethod ipinfo.io/json).ip



Get-AzSubscription -SubscriptionId a7bbf1cf-cf04-494e-ab27-398f92bf16ce | Select-AzSubscription
$rg = Get-AzResourceGroup -Name $AzResourceGroupName

#Stworzenie publicznego adresu IP
$PublicIpDynamicRez = New-AzResourceGroupDeployment -Name "PublicIpDynamic" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\ARM\TESTAD\CreatPubIp.json" `
    -location $rg.Location `
    -PublicIpAddr $PublicIpAddrName

$WirtualnaSiecRez = New-AzResourceGroupDeployment -Name "WirtualnaSiec" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\ARM\TESTAD\dTVNet.json" `
    -location $rg.Location `
    -virtualNetworkName $VirtualNetworkName

$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg.ResourceGroupName -Name $VirtualNetworkName

$WirtualnaMaszynaRezAD = New-AzResourceGroupDeployment -Name "WirtualnaMaszynaAD" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\ARM\TESTAD\CreatVM.json" `
    -location $rg.Location `
    -subnetName $vnet.Subnets[0].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmADName `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsServer" `
    -ImageOffer "WindowsServer" `
    -ImageSku "2019-datacenter" `
    -mojeIpComputera $PubIpMyComp

$WirtualnaMaszynaRezMGMT = New-AzResourceGroupDeployment -Name "WirtualnaMaszyna" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\ARM\TESTAD\CreatVM.json" `
    -location $rg.Location `
    -subnetName $vnet.Subnets[1].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmMGMTName `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsServer" `
    -ImageOffer "WindowsServer" `
    -ImageSku "2019-datacenter" `
    -mojeIpComputera $PubIpMyComp

$WirtualnaMaszynaRezWIN10 = New-AzResourceGroupDeployment -Name "WirtualnaMaszyna" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\ARM\TESTAD\CreatVM.json" `
    -subnetName $vnet.Subnets[1].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmWIN10Name `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsDesktop" `
    -ImageOffer "Windows-10" `
    -ImageSku "20h2-ent" `
    -mojeIpComputera $PubIpMyComp

$nic = Get-AzNetworkInterface -Name "$($vmMGMTName)_nic" -ResourceGroupName $RG.ResourceGroupName
$pip = Get-AzPublicIpAddress -Name "$PublicIpAddrname" -ResourceGroupName $RG.ResourceGroupName
$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations.Name -PublicIpAddress $pip | Out-Null
$nic | Set-AzNetworkInterface | Out-Null