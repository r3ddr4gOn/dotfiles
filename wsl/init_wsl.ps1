# Init clean WSL distro
#
# Note: This uses the current working directory as the base to store images and wsl disk files (images\ and disks\ subfolders)

# Parse parameters
param ($distro_name, $username="wsl")

$ErrorActionPreference = "Stop"

if ($distro_name -eq $null) {
    $distro_name = read-host -Prompt "Please enter the name of the new wsl distro. It will be based on Ubuntu 22.04." 
}

# Download image (Hardcoded to Ubuntu 22 for now)
$distro_image_url="https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64.rootfs.tar.gz"
$distro_image_name = "ubuntu-jammy-wsl-amd64.rootfs.tar.gz"
if (-Not (Test-Path ".\images\$distro_image_name" -PathType Leaf)) {
    md -Force ".\images" | Out-Null
    $wc = New-Object net.webclient
    $wc.Downloadfile("$distro_image_url", ".\images\$distro_image_name")
}

# Initialize distro with user
md -Force ".\disks" | Out-Null
& wsl --import "$distro_name" ".\disks\$distro_name" ".\images\$distro_image_name"
if (-not $?) {throw "Failed to import image"}

& wsl -d $distro_name -e "./init_user.sh" "$username"
if (-not $?) {throw "Failed to create wsl user"}

& wsl --terminate $distro_name
if (-not $?) {throw "Failed to shutdown the wsl distro"}

# Generate shortcut
$WshShell = New-Object -comObject WScript.Shell
$workdir = (Get-Item .).FullName
$Shortcut = $WshShell.CreateShortcut($workdir + "\Launch` $distro_name.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\wsl.exe"
$Shortcut.Arguments = "-d $distro_name --cd /home/$username"
$Shortcut.Save()

write-host "Distro initialized. You can now launch it using the Shortcut that was generated in the working directory."
write-host "To uninstall the distro and remove it's harddrive simply run \"wsl --unregister $distro_name\""