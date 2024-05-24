$Email = "jayremnt@gmail.com"
$DownloadsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')
$ProjectsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'projects')

if (-Not (Test-Path -Path $ProjectsPath))
{
  New-Item -ItemType Directory -Path $ProjectsPath | Out-Null
}

Write-Host "Installing Chocolatey..."
if (-Not (Get-Command choco -ErrorAction SilentlyContinue))
{
  Write-Host "Installing Chocolatey..."
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

Write-Host "Installing Software and CLIs..."
$ChocoInstallations = @(
  "git",
  "gh",
  "github"
  "nvm",
  "python",
  "docker-desktop",
  "googlechrome",
  "spotify",
  "discord",
  "postman",
  "teamviewer",
  "ultraviewer.install",
  "telegram"
  "7zip"
)

foreach ($Installation in $ChocoInstallations)
{
  choco install -y $Installation
}

Write-Host "Installing NPM and Yarn..."
nvm install latest
nvm use latest
npm i yarn -g

# Adobe Creative Cloud, just open the URL
# TODO: Why is it not opening the URL?
Write-Host "Opening Adobe Creative Cloud Download URL..."
$AdobeCreativeCloudInstallationURL = "https://creativecloud.adobe.com/apps/download/creative-cloud"

Start-Process $AdobeCreativeCloudInstallationURL

# Install some software
function Install-Software
{
  param (
    [string]$DownloadURL,
    [string]$FileName,
    [string]$SoftwareName
  )

  $FilePath = [System.IO.Path]::Combine($DownloadsPath, $FileName)

  Write-Host "Installing $SoftwareName..."
  try
  {
    Invoke-WebRequest -Uri $DownloadURL -OutFile $FilePath
    Start-Process -FilePath $FilePath
  }
  catch
  {
    Write-Host "Failed to install $SoftwareName : $_"
  }
}

$Softwares = @(
  @{
    DownloadURL = "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.vn2.exe"
    FileName = "Install League of Legends vn2.exe"
    Name = "League of Legends"
  },
  @{
    DownloadURL = "https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.3.1.31116.exe"
    FileName = "jetbrains-toolbox-2.3.1.31116.exe"
    Name = "Jetbrains Toolbox"
  },
  # TODO: Sometimes it shows - Failed to install Visual Studio : The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.
  @{
    DownloadURL = "https://c2rsetup.officeapps.live.com/c2r/downloadVS.aspx?sku=community&channel=Release&version=VS2022&source=VSLandingPage"
    FileName = "VisualStudioSetup.exe"
    Name = "Visual Studio"
  }
)

foreach ($Software in $Softwares)
{
  Install-Software -DownloadURL $Software.DownloadURL -FileName $Software.FileName -SoftwareName $Software.Name
}

Write-Host "Installing EVKey..."
$EVKeyProjectPath = [System.IO.Path]::Combine($DownloadsPath, 'EVKey')
$EVKeyExePath = [System.IO.Path]::Combine($DownloadsPath, 'EVKey', 'release', 'EVKey64.exe')

git clone "https://github.com/lamquangminh/EVKey.git" $EVKeyProjectPath
Start-Process -FilePath $EVKeyExePath

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

# Microsoft Activation Scripts
irm https://get.activated.win | iex
