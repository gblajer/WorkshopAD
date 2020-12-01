$AzResourceGroupName = "TESTAD"
$VirtualNetworkName = "$($AzResourceGroupName)vNet"
$PublicIpAddrName = "$($AzResourceGroupName)PubIp"
$vmADName = "WINAD01"
$vmMGMTName = "WINMGMT01"
$vmWIN10Name = "WIN1001"
$adminUsername = "secmaster"
$Secure_String_Pwd = ConvertTo-SecureString "P@ssword123!@#" -AsPlainText -Force
$PubIpMyComp = "89.64.54.128"
$SubscriptionId = "0f2b453d-4acb-4ccb-b1ee-b40c82dd875d"

Import-Module AZ

Get-AzSubscription -SubscriptionId $SubscriptionId | Select-AzSubscription
$rg = Get-AzResourceGroup -Name $AzResourceGroupName

Write-Host "Utworzenie publicznego adresu IP." -ForegroundColor Green
$PublicIpDynamicRez = New-AzResourceGroupDeployment -Name "PublicIpDynamic" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\CreatPubIp.json" `
    -PublicIpAddr $PublicIpAddrName

Write-Host "Utworzenie wirtualnej sieci." -ForegroundColor Green
$WirtualnaSiecRez = New-AzResourceGroupDeployment -Name "WirtualnaSiec" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\dTVNet.json" `
    -virtualNetworkName $VirtualNetworkName

$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg.ResourceGroupName -Name $VirtualNetworkName

Write-Host "Utworzenie wirtualnej maszyny $vmADName." -ForegroundColor Green
$WirtualnaMaszynaRezAD = New-AzResourceGroupDeployment -Name "WirtualnaMaszynaAD" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\CreatVM.json" `
    -subnetName $vnet.Subnets[0].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmADName `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsServer" `
    -ImageOffer "WindowsServer" `
    -ImageSku "2019-datacenter" `
    -mojeIpComputera $PubIpMyComp `
    -AsJob

Write-Host "Utworzenie wirtualnej maszyny $vmMGMTName." -ForegroundColor Green
$WirtualnaMaszynaRezMGMT = New-AzResourceGroupDeployment -Name "WirtualnaMaszynaMGMT" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\CreatVM.json" `
    -subnetName $vnet.Subnets[1].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmMGMTName `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsServer" `
    -ImageOffer "WindowsServer" `
    -ImageSku "2019-datacenter" `
    -mojeIpComputera $PubIpMyComp `
    -AsJob

Write-Host "Utworzenie wirtualnej maszyny $vmWIN10Name." -ForegroundColor Green
$WirtualnaMaszynaRezWIN10 = New-AzResourceGroupDeployment -Name "WirtualnaMaszynaWIN10" -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\CreatVM.json" `
    -subnetName $vnet.Subnets[1].Name `
    -virtualNetworkId $vnet.Id `
    -virtualMachineName $vmWIN10Name `
    -adminUsername $adminUsername `
    -adminPassword $Secure_String_Pwd `
    -ImagePublisher "MicrosoftWindowsDesktop" `
    -ImageOffer "Windows-10" `
    -ImageSku "20h2-ent" `
    -mojeIpComputera $PubIpMyComp `
    -AsJob

Write-Host "Pausa na 45 sekund." -ForegroundColor Green
Start-Sleep -Seconds 45

Write-Host "Przypisanie publicznego adresu IP do serwera $vmMGMTName." -ForegroundColor Green
$nic = Get-AzNetworkInterface -Name "$($vmMGMTName)_nic" -ResourceGroupName $RG.ResourceGroupName
$pip = Get-AzPublicIpAddress -Name "$PublicIpAddrname" -ResourceGroupName $RG.ResourceGroupName
$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations.Name -PublicIpAddress $pip | Out-Null
$nic | Set-AzNetworkInterface | Out-Null