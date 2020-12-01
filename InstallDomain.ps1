$domenaNazwa = "jakasdomena.xyz"
$NetbosName = $domenaNazwa.Split(".")[0]
$Secure_String_Pwd = ConvertTo-SecureString "P@ssword123!@#" -AsPlainText -Force
Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest `
    -DomainName $domenaNazwa `
    -SafeModeAdministratorPassword $Secure_String_Pwd `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "7" `
    -DomainNetbiosName $NetbosName `
    -ForestMode "7" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$True `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true