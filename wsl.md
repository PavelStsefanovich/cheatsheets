# Install and configure WSL v2


## Install WSL v2

### Windows 10 version 2004+ (build 19041+)
```powershell
    wsl --install
```

### Older Windows versions
1. Enable WSL Feature:
```powershell
    # cmd
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    # powershell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
```

2. Download and install Linux kernel update: [wsl_update_x64.msi](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

3. Restart computer to apply changes.

4. Configure WSL2 to be used by default:
```powershell
    wsl --set-default-version 2
```

## Install First WSL Distribution

1. Download and install Ubuntu distro:
```powershell
    # define the installation directory (no need to create directory beforehand)
    $install_directory = "D:\your\dir" # can be any drive/path

    # download Ubuntu distro
    $download_path = Join-Path $HOME '\Downloads\ubuntu.zip'
    $unzip_dir = Join-Path $HOME '\Downloads\ubuntu'
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile('https://aka.ms/wslubuntu2004', "$($download_path.Replace('\','\\'))")

    # unpack Ubuntu distro
    Expand-Archive "$download_path" "$unzip_dir"
    Expand-Archive "$((Get-Item "$unzip_dir\*_x64.appx").FullName)" "$install_directory"
    Remove-Item $download_path, $unzip_dir -Force -Recurse

    # install Ubuntu distro
    Invoke-Item "$((Get-Item "$install_directory\*.exe").FullName)"
```

2. Follow the prompts inside the WSL terminal window to create admin user/password. These are not related to your Windows account username/passord and can be anything.

3. Add your admin user to the sudoers (inside the WSL terminal window):
```bash
    sudo usermod -aG sudo <username>
```

4. Exit WSL terminal window and restart WSL:
```powershell
    wsl --shutdown
```

## Install Additional WSL Distribution(s)

1. Find the distribution of your choice on the [Ubuntu Cloud Images](http://cloud-images.ubuntu.com/) repository.

2. Download, Import and Start the new distribution:
```powershell
    # download
    $wc = [System.Net.WebClient]::new()
    $wc.DownloadFile('http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-wsl.rootfs.tar.gz', "$((Join-Path $HOME '\Downloads\ub2004lts.tar.gz').Replace('\','\\'))")
    # import
    wsl --import <new_distro_name> <path_to_new_distro_home_dir> "$((Join-Path $HOME '\Downloads\ub2004lts.tar.gz').Replace('\','\\'))"
    # start
    wsl -d <new_distro_name>
```

3. Create admin user, add it to sudoers and make it a default login (inside the WSL terminal window):
```bash
    # do this first
    adminuser="<username>"
    adduser $adminuser

    # do this next:
    adduser $adminuser sudo
    tee /etc/wsl.conf <<BLOCK
    [user]
    default=$adminuser
    BLOCK
```

4. Exit WSL terminal window and restart WSL distribution:
```powershell
    wsl -t <new_distro_name>
```


## WSL Initial Config
```bash
    # update package manager and upgrade installed packages
    sudo apt update -y && sudo apt upgrade -y

    # remove the message of the day (known as MOTD)
    touch ~/.hushlogin
```

## Initial Backup
```powershell
    wsl --export "<new_distro_name>-clean" <path_to_backup_tar_file>
```
