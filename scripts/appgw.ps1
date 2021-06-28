# Prepare the env
$publicip = Get-AzPublicIpAddress -ResourceGroupName Default -name mypublicip
$vnet = Get-AzVirtualNetwork -ResourceGroupName Default -name testlinuxvnet
$gwSubnet = Get-AzVirtualNetworkSubnetConfig -Name "appgwSubnet" -VirtualNetwork $vnet

# Set AGW elements
$gipconfig = New-AzApplicationGatewayIPConfiguration -Name "AppGwIpConfig" -Subnet $gwSubnet
$fipconfig01 = New-AzApplicationGatewayFrontendIPConfig -Name "fipconfig" -PublicIPAddress $publicip
$pool = New-AzApplicationGatewayBackendAddressPool -Name "pool1"
$fp01 = New-AzApplicationGatewayFrontendPort -Name "port1" -Port 443

# Init AGW sslcert
$certificate = Get-AzKeyVaultCertificate -VaultName keyvault-1614619090 -Name testcert1
$secretId = $certificate.SecretId.Replace($certificate.Version, "")
$sslCert01 = New-AzApplicationGatewaySslCertificate -Name "SSLCert1" -KeyVaultSecretId $secretId


$listener01 = New-AzApplicationGatewayHttpListener -Name "listener1" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $sslCert01
$poolSetting01 = New-AzApplicationGatewayBackendHttpSettings -Name "setting1" -Port 80 -Protocol Http -CookieBasedAffinity Disabled
$rule01 = New-AzApplicationGatewayRequestRoutingRule -Name "rule1" -RuleType basic -BackendHttpSettings $poolSetting01 -HttpListener $listener01 -BackendAddressPool $pool


$appgwIdentity = New-AzApplicationGatewayIdentity -UserAssignedIdentityId /subscriptions/3475e05d-2753-47d4-9337-98dd2c5cf78a/resourceGroups/Default/providers/Microsoft.ManagedIdentity/userAssignedIdentities/appgwid
$managedIdentity = Get-AzADServicePrincipal -DisplayName appgwid
Set-AzKeyVaultAccessPolicy -VaultName keyvault-1614619090 -PermissionsToSecrets get -ObjectId $managedIdentity.Id
$autoscaleConfig = New-AzApplicationGatewayAutoscaleConfiguration -MinCapacity 1
$sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2
$appgw = New-AzApplicationGateway -Name appgw22 -Identity $appgwIdentity -ResourceGroupName rg-eastus -Location "East US" -BackendAddressPools $pool -BackendHttpSettingsCollection $poolSetting01 -GatewayIpConfigurations $gipconfig -FrontendIpConfigurations $fipconfig01 -FrontendPorts $fp01 -HttpListeners $listener01 -Sku $sku -SslCertificates $sslCert01 -RequestRoutingRules $rule01 -AutoscaleConfiguration $autoscaleConfig
