#!/usr/bin/env pwsh
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$RootDirectory = ".",
    [Parameter(Position = 1)]
    [switch]$CreateCommit
)

$resolvedRootDirectory = (Resolve-Path -Path $RootDirectory -ErrorAction "Stop").Path

if ([System.IO.FileAttributes]::Directory -notin (Get-Item -Path $resolvedRootDirectory).Attributes) {
    $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
            [System.IO.IOException]::new("Supplied root directory path is not a directory."),
            "InvalidRootDirectoryPath",
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $resolvedRootDirectory
        )
    )
}

$ipRangesListsPath = Join-Path -Path $resolvedRootDirectory -ChildPath "blocked_ip_ranges"
$ipRangesOutPath = Join-Path -Path $resolvedRootDirectory -ChildPath "modsecurity/blocked_ip_ranges.data"

$ipRangesLists = Get-ChildItem -Path $ipRangesListsPath | Where-Object { $PSItem.Extension -in @(".yml", ".yaml") }

$allIpRanges = [System.Collections.Generic.List[string]]::new()

foreach ($ipRangeListItem in $ipRangesLists) {
    $ipRangeDocument = Get-Content -Path $ipRangeListItem.FullName -Raw | ConvertFrom-Yaml

    Write-Verbose -Message "Processing '$($ipRangeDocument["name"])'"

    foreach ($rangeItem in $ipRangeDocument["ipRanges"]) {
        $allIpRanges.Add($rangeItem)
    }
}

$allIpRanges = $allIpRanges | Sort-Object

$ipRangesStringBuilder = [System.Text.StringBuilder]::new()
foreach ($rangeItem in $allIpRanges) {
    $null = $ipRangesStringBuilder.AppendLine($rangeItem)
}

if ($PSCmdlet.ShouldProcess($ipRangesOutPath, "Update IP ranges data file")) {
    $ipRangesStringBuilder.ToString() | Out-File -FilePath $ipRangesOutPath -Encoding "UTF8" -Force
}
else {
    $ipRangesStringBuilder.ToString().TrimEnd() | Write-Output
}

if ($CreateCommit) {
    if ($PSCmdlet.ShouldProcess($ipRangesOutPath, "Commit changes")) {
        git add "$($ipRangesOutPath)"
        $currentTimeStamp = [System.DateTimeOffset]::Now.UtcDateTime.ToString("yyyy-MM-dd HH:mm:ss zzz")

        git commit --message "Merged IP ranges [$($currentTimeStamp)]"
    }
}
