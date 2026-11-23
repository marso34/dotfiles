<#
.SYNOPSIS
    Windows 기본 앱 제거(remove-apps.txt) + GUI 앱 설치(winget configure)
    wsl/install.sh가 호출하며, 직접 실행해도 됨

.DESCRIPTION
    Windows PowerShell 5.1 호환 (pwsh 전용 문법 사용 금지), UTF-8 BOM으로 저장
    관리자 권한 불필요 — securityContext: elevated 리소스가 있으면 winget이 UAC를 한 번 요청

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\apps.ps1 work
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = '사람이 지켜보는 설치 스크립트의 진행 메시지')]
param(
    [Parameter(Position = 0)]
    [ValidateSet('personal', 'work', 'full', 'ci')]
    [string]$InstallProfile = 'full'
)

$ErrorActionPreference = 'Stop'

# WSL에서 호출될 때 한글 출력이 깨지지 않도록 (콘솔이 없는 환경에선 예외가 날 수 있어 무시)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { Write-Verbose '콘솔 출력 인코딩 설정 생략' }

# 프로파일 → winget 파일 (Brewfile 프로파일과 동일한 규칙)
switch ($InstallProfile) {
    'personal' { $names = @('common', 'personal') }
    'work'     { $names = @('common', 'work') }
    'full'     { $names = @('common', 'work', 'personal') }
    'ci'       { $names = @() }
}

if ($names.Count -eq 0) {
    Write-Host "프로파일 '$InstallProfile': 설치할 Windows 앱 없음"
    exit 0
}

$failed = @()

# ── 기본 앱 제거 (현재 사용자, 관리자 권한 불필요) ──
$removeList = Join-Path $PSScriptRoot 'remove-apps.txt'
if (Test-Path $removeList) {
    Write-Host ""
    Write-Host '🗑️  Windows 기본 앱 제거 (remove-apps.txt)'

    $appNames = Get-Content $removeList -Encoding UTF8 |
        ForEach-Object { ($_ -replace '#.*$', '').Trim() } |
        Where-Object { $_ }

    foreach ($appName in $appNames) {
        $pkgs = @(Get-AppxPackage -Name $appName -ErrorAction SilentlyContinue)
        if ($pkgs.Count -eq 0) {
            Write-Host "   - $appName (설치되어 있지 않음)"
            continue
        }
        foreach ($pkg in $pkgs) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                Write-Host "   ✓ $appName 제거"
            }
            catch {
                Write-Warning "$appName 제거 실패: $($_.Exception.Message)"
                $failed += "remove:$appName"
            }
        }
    }
}

# ── GUI 앱 설치 ──
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget이 없습니다. Microsoft Store에서 "앱 설치 관리자(App Installer)"를 설치/업데이트하세요.'
}

$wingetDir = Join-Path $PSScriptRoot 'winget'

foreach ($name in $names) {
    $file = Join-Path $wingetDir "$name.winget"
    Write-Host ""
    Write-Host "📦 winget configure: $name.winget (profile: $InstallProfile)"

    winget configure --file $file --accept-configuration-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$name.winget 적용 중 일부 실패 (exit $LASTEXITCODE)"
        $failed += $name
    }
}

Write-Host ""
if ($failed.Count -gt 0) {
    Write-Warning ("실패: " + ($failed -join ', ') + " — 다시 실행하면 완료된 항목은 건너뜀")
    exit 1
}
Write-Host '✅ Windows 앱 정리 · 설치 완료'
