$Email = "jayremnt@gmail.com"
$DownloadsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')

Write-Host "Installing Chocolatey..."
if (-Not (Get-Command choco -ErrorAction SilentlyContinue))
{
  Write-Host "Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Installing Software and CLIs..."
$ChocoInstallations = @(
  "git",
  "gh",
  "github"
  "nvm",
  "docker-desktop",
  "jetbrainstoolbox",
  "googlechrome",
  "spotify",
  "discord",
  "postman",
  "teamviewer-qs",
  "ultraviewer.install",
  "telegram"
  "7zip"
)

foreach ($installation in $ChocoInstallations)
{
  choco install -y $installation
}

# NPM and Yarn
nvm install latest
nvm use latest
npm i yarn -g

# Adobe Creative Cloud, just open the URL
Write-Host "Opening Adobe Creative Cloud Download URL..."
$adobeCreativeCloudInstallationURL = "https://creativecloud.adobe.com/apps/download/creative-cloud"

Start-Process $adobeCreativeCloudInstallationURL

# EVKey
Write-Host "Installing EVKey..."
$EVKeyZipDownloadUrl = "https://github.com/lamquangminh/EVKey/releases/download/Release/EVKey.zip"
$EVKeyZipFilePath = [System.IO.Path]::Combine($DownloadsPath, 'EVKey.zip')
$EVKeyExtractPath = [System.IO.Path]::Combine($DownloadsPath, 'EVKey')

try
{
  Invoke-WebRequest -Uri $EVKeyZipDownloadUrl -OutFile $EVKeyZipFilePath
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($EVKeyZipFilePath, $EVKeyExtractPath)
  Start-Process -FilePath "$EVKeyExtractPath\EVKey64.exe"
}
catch
{
  Write-Host "Failed to install EVKey: $_"
}

# League of Legends
Write-Host "Installing League of Legends..."
$LOLDownloadURL = "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.vn2.exe"
$LOLFilePath = [System.IO.Path]::Combine($DownloadsPath, 'Install League of Legends vn2.exe')

try
{
  Invoke-WebRequest -Uri $LOLDownloadURL -OutFile $LOLFilePath
  Start-Process -FilePath $LOLFilePath
}
catch
{
  Write-Host "Failed to install League of Legends: $_"
}

# Generate SSH key
Write-Host "Generating SSH Key..."
$SSHKeyPath = [System.IO.Path]::Combine($env:USERPROFILE, '.ssh', 'id_ed25519')

if (-Not (Test-Path -Path "$env:USERPROFILE\.ssh"))
{
  New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" | Out-Null
}

if (Test-Path -Path $SSHKeyPath)
{
  Remove-Item -Path $SSHKeyPath -Force
}

ssh-keygen -t ed25519 -C $Email -f $SSHKeyPath -N '""'
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent
ssh-add $SSHKeyPath
Get-Content "$SSHKeyPath.pub" | Set-Clipboard

Write-Host "Copied SSH Key to the clipboard"
Start-Process "https://github.com/settings/ssh/new"
