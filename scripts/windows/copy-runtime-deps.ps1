param(
    [Parameter(Mandatory = $true)]
    [string]$Dumpbin,
    [Parameter(Mandatory = $true)]
    [string]$SourceBin,
    [Parameter(Mandatory = $true)]
    [string]$TargetDir,
    [string]$EntryExe = "appKhinsiderQT.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Dumpbin)) {
    Write-Error "dumpbin.exe not found: $Dumpbin"
    exit 1
}
if (-not (Test-Path -LiteralPath $SourceBin)) {
    Write-Error "Source bin path not found: $SourceBin"
    exit 1
}
if (-not (Test-Path -LiteralPath $TargetDir)) {
    Write-Error "Target directory not found: $TargetDir"
    exit 1
}

$systemDlls = @(
    "kernel32.dll", "user32.dll", "gdi32.dll", "shell32.dll", "ole32.dll", "oleaut32.dll",
    "advapi32.dll", "ws2_32.dll", "wldap32.dll", "crypt32.dll", "bcrypt.dll", "dnsapi.dll",
    "iphlpapi.dll", "secur32.dll", "winhttp.dll", "mpr.dll", "userenv.dll", "authz.dll",
    "d3d11.dll", "d3d12.dll", "dxgi.dll", "dwrite.dll", "imm32.dll", "comdlg32.dll",
    "shlwapi.dll", "winmm.dll", "version.dll", "setupapi.dll", "nsi.dll", "wsock32.dll",
    "netapi32.dll", "rpcrt4.dll", "msvcp_win.dll"
)

$systemSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($dll in $systemDlls) {
    [void]$systemSet.Add($dll)
}

$queue = [System.Collections.Generic.Queue[string]]::new()
$seenFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$missingDeps = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

$entryPath = Join-Path $TargetDir $EntryExe
if (Test-Path -LiteralPath $entryPath) {
    $queue.Enqueue($entryPath)
}

Get-ChildItem -LiteralPath $TargetDir -Filter "*.dll" -File | ForEach-Object {
    $queue.Enqueue($_.FullName)
}

while ($queue.Count -gt 0) {
    $currentFile = $queue.Dequeue()
    if (-not (Test-Path -LiteralPath $currentFile)) {
        continue
    }
    if (-not $seenFiles.Add($currentFile)) {
        continue
    }

    $dumpOutput = & $Dumpbin /DEPENDENTS $currentFile 2>$null
    foreach ($line in $dumpOutput) {
        if ($line -notmatch '^\s+([A-Za-z0-9_.-]+\.dll)\s*$') {
            continue
        }

        $dependencyName = $matches[1]
        $dependencyLower = $dependencyName.ToLowerInvariant()
        if ($dependencyLower.StartsWith("api-ms-win-")) {
            continue
        }
        if ($systemSet.Contains($dependencyName)) {
            continue
        }

        $targetDependency = Join-Path $TargetDir $dependencyName
        if (Test-Path -LiteralPath $targetDependency) {
            $queue.Enqueue($targetDependency)
            continue
        }

        $sourceDependency = Join-Path $SourceBin $dependencyName
        if (Test-Path -LiteralPath $sourceDependency) {
            Copy-Item -LiteralPath $sourceDependency -Destination $targetDependency -Force
            Write-Output "Copied transitive $dependencyName"
            $queue.Enqueue($targetDependency)
        } else {
            [void]$missingDeps.Add($dependencyName)
        }
    }
}

if ($missingDeps.Count -gt 0) {
    Write-Warning ("Missing transitive dependencies in source bin: " + (($missingDeps | Sort-Object) -join ", "))
}

exit 0
