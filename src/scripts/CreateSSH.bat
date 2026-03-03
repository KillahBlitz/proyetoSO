Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service sshd -StartupType Automatic
New-NetFirewallRule -Name sshd -DisplayName "OpenSSH" -Protocol TCP -LocalPort 22 -Action Allow

net user admin admin /add
net localgroup administrators admin /add
