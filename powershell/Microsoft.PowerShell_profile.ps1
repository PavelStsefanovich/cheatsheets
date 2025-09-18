# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}


# ENVIRONMENT VARIABLES
# $env:PSModulePath = $env:PSModulePath.TrimEnd(';') + ';<additional_module_path>'
$env:path = $env:path.trim(';') + ';D:\scripts;'



# FUNCTIONS
function prompt {
    $current_location = $pwd.Path
    (Get-Host).UI.RawUI.WindowTitle = $title.replace('<path>', $current_location)
    $prompt = "`n$(split-path $current_location -leaf)/> "
    $prompt
}

function list-utils { listmc (Get-Module UtilityFunctions) }



# MODULES
$modules_to_install = @('UtilityFunctions', 'WinRegistry')
$modules_to_install | % { Import-Module $_ -Force -DisableNameChecking }



# DEFAULTS
$host.PrivateData.ErrorBackgroundColor = $host.UI.RawUI.BackgroundColor
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$default_locations = @(
    'C:\Windows\system32',
    'C:\Windows\System32\WindowsPowerShell\v1.0',
    'C:\Program Files\PowerShell\7',
    $HOME)
$working_directory = 'D:\WORKSHOP'



# TITLE
$title = whoami
if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { $title += "  ADMIN" }
else { $title += "  (no admin)" }
$title += "   <path>"
(Get-Host).UI.RawUI.WindowTitle = $title



# HEADER
$psversion = ($PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor) -join ('.')
write "PowerShell `e[45;30m$psversion`e[0m" # For PowerShell prior to v7: write ("PowerShell " + [char]0x1b + "[46;30m" + $psversion + [char]0x1b + "[0m")
write "STARTED ON:`t$(get-date -UFormat %c)`n"



# SET ALIASES
Set-Alias -Name npp -Value "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias -Name utils -Value list-utils



# PRINT ALIASES
write "`nALIASES:"
$amap = @{
    'npp' = (Get-Alias npp).Definition
    'utils' = (Get-Alias utils).Definition
}
$amap.keys | sort | %{ write (" $_" + " "*(20 - $_.length) + "--> $($amap.$_)")}



# WORKING DIRECTORY
if ($pwd.Path -in $default_locations) {
    try { cd $working_directory -ErrorAction Stop }
    catch { Write-Warning "Directory not found: `"$working_directory`"" }
}



# FOOTER
(([string][char]9552))*($Host.UI.RawUI.WindowSize.Width)
