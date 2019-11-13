# script to setup ssh on a windows server to permit remote powershell from linux / mac
# first get the installer

$tmpdir = "c:\tempadr"
$dir = "C:\Program Files\OpenSSH"
$install_file = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.0.0.0p1-Beta/OpenSSH-Win64.zip"

if(!(Test-Path -Path $tmpdir )){
    New-Item -ItemType directory -Path $tmpdir
    Write-Host "New folder created"
} else
{
  Write-Host "Folder already exists"
}

cd $tmpdir
wget $install_file -outfile OpenSSH.zip
Expand-Archive -LiteralPath OpenSSH.zip -DestinationPath "C:\Program Files"
Move-Item -Path "C:\Program Files\OpenSSH-Win64" -Destination "C:\Program Files\OpenSSH"

Set-ExecutionPolicy Bypass
cd $dir
.\install-sshd.ps1
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
net start sshd
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic

#
# set default login shell to powershell version 6 - install it using iex with a silent option
#
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
Set-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" -Value "C:\Program Files\PowerShell\6\pwsh.exe"
#Set-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name "DefaultShell" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

Restart-Service sshd
