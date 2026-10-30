param (
    [Parameter(Mandatory = $true)]
    [string]$AppDir,
    [Parameter(Mandatory = $true)]
    [string]$PersistDir
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Functions.ps1"
$firefoxRoot = Join-Path $env:APPDATA 'Mozilla\Firefox'
if ((Test-Path -LiteralPath $firefoxRoot) -and (Get-Item -LiteralPath $firefoxRoot).LinkType) {
    throw "Firefox root $firefoxRoot is a link from an earlier installation. Restore it to a normal directory before installing; its target has been left unchanged."
}
if (Get-Process firefox -ErrorAction SilentlyContinue) {
    throw 'Close all Firefox windows before installing or updating so profiles can be migrated safely.'
}

# Let Firefox select/register its own default, including on a fresh installation.
# The screenshot is kept in TEMP; no user profile files are removed here.
$screenshot = Join-Path $env:TEMP ('firefox-profile-init-' + [guid]::NewGuid().ToString('N') + '.png')
$process = Start-Process -FilePath (Join-Path $AppDir 'firefox.exe') -ArgumentList @('--headless', '--no-remote', '--screenshot', "`"$screenshot`"", 'about:blank') -WindowStyle Hidden -Wait -PassThru
if ($process.ExitCode -ne 0) {
    throw "Firefox profile initialization failed with exit code $($process.ExitCode)."
}

$appPaths = @([IO.Path]::GetFullPath($AppDir).TrimEnd('\'))
$appItem = Get-Item -LiteralPath $AppDir
if ($appItem.LinkType) {
    $appPaths += [IO.Path]::GetFullPath($appItem.Target).TrimEnd('\')
}
$profilesIni = Get-Content -LiteralPath (Join-Path $firefoxRoot 'profiles.ini') -Raw
$profiles = @()
foreach ($section in [regex]::Matches($profilesIni, '(?ms)^\[Profile\d+\]\s*\r?\n(.*?)(?=^\[|\z)')) {
    $pathMatch = [regex]::Match($section.Groups[1].Value, '(?m)^Path=(.+?)\r?$')
    if (!$pathMatch.Success) { continue }
    $profilePath = $pathMatch.Groups[1].Value.Replace('/', '\')
    if ($section.Groups[1].Value -match '(?m)^IsRelative=1\r?$') {
        $profilePath = Join-Path $firefoxRoot $profilePath
    }
    $compatibility = Join-Path $profilePath 'compatibility.ini'
    if (!(Test-Path -LiteralPath $compatibility)) { continue }
    $lastApp = [regex]::Match((Get-Content -LiteralPath $compatibility -Raw), '(?m)^LastPlatformDir=(.+?)\r?$')
    if ($lastApp.Success -and $appPaths -contains [IO.Path]::GetFullPath($lastApp.Groups[1].Value).TrimEnd('\')) {
        $profiles += $profilePath
    }
}
if (!$profiles.Count) {
    throw 'Cannot identify a profile belonging to this Firefox installation; no profile directories were moved.'
}
foreach ($profilePath in $profiles | Select-Object -Unique) {
    $destination = Join-Path $PersistDir ('Profiles\' + (Split-Path $profilePath -Leaf))
    Move-Data_dir -data_dir $profilePath -persist_dir $destination
}
