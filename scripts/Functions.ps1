function Move-Data_dir {
    param (
        [string]$data_dir,
        [string]$persist_dir
    )
    if (!(Test-Path $persist_dir)) {
        New-Item -ItemType Directory -Path $persist_dir | Out-Null
    }
    if (Test-Path $data_dir) {
        $testlink = (Get-Item $data_dir).LinkType
        if ($testlink -ne "Junction") {
            Write-Host "Moving data from $data_dir to $persist_dir"
            Get-ChildItem -Path $data_dir | ForEach-Object {
                $source = $_.FullName
                $destination = Join-Path -Path $persist_dir -ChildPath $_.Name
                Move-Item -Path $source -Destination $destination
            }
        }
        else {
            Write-Host "$data_dir is already a junction. Skipping move."
        }
        Remove-Item -Path $data_dir -Recurse -Force
    }
    Write-Host "Creating junction from $data_dir to $persist_dir"
    New-Item -ItemType Junction -Path $data_dir -Target $persist_dir | Out-Null
}
