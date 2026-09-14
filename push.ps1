# 去口语化手册与技能包 —— 一键推送到 GitHub 私有仓库
# 用法：在本目录右键"使用 PowerShell 运行"，或在 PowerShell 里执行 .\push.ps1
# 令牌仅用于本次推送，不会写入 .git/config

$ErrorActionPreference = 'Stop'

# 0) 定位 git（本机为便携版，可能不在 PATH）
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) {
    $guess = Join-Path $env:USERPROFILE '.qwenworkcn\bin\git\mingw64\bin\git.exe'
    if (Test-Path $guess) { $git = $guess } else { Write-Host '未找到 git，请先安装 Git for Windows' -ForegroundColor Red; exit 1 }
}
Write-Host "使用 git: $git" -ForegroundColor DarkGray

# 1) 收集信息
$user  = Read-Host 'GitHub 用户名'
$repo  = Read-Host '仓库名（先在 GitHub 网页建好【私有】仓库，此处填同名）'
$email = Read-Host '提交邮箱（建议用 GitHub 的 noreply 邮箱，避免暴露真实邮箱）'
$name  = Read-Host '提交署名（如 Lucia Wang）'
Write-Host '接下来输入令牌：GitHub → Settings → Developer settings → Fine-grained tokens' -ForegroundColor Yellow
Write-Host '权限只需 Contents: Read and write，范围限定为该仓库，建议有效期 7 天' -ForegroundColor Yellow
$sec   = Read-Host 'Personal Access Token（粘贴后不显示）' -AsSecureString
$token = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))

Set-Location $PSScriptRoot

# 2) 初始化与提交
if (-not (Test-Path '.git')) {
    & $git init -b main | Out-Null
}
& $git config user.name  $name
& $git config user.email $email
& $git add .
& $git commit -m "Add 去口语化工作手册 v1.5/v1.6 与 steno-decolloquialize 技能包 v2.2"

# 3) 推送（令牌只出现在这一条命令里）
$pushUrl = "https://x-access-token:$token@github.com/$user/$repo.git"
Write-Host "推送到 github.com/$user/$repo (main) ..." -ForegroundColor Cyan
& $git push $pushUrl main:main

# 4) 落一个不含令牌的 remote，方便以后用别的凭据方式继续协作
& $git remote remove origin 2>$null
& $git remote add origin "https://github.com/$user/$repo.git"

# 5) 清理内存中的令牌变量
$token = $null; $sec = $null

Write-Host ''
Write-Host '✅ 推送完成。请回到 GitHub 网页刷新仓库确认文件已上传。' -ForegroundColor Green
Write-Host '👉 用完请立刻到 GitHub 撤销该令牌（Settings → Developer settings → Fine-grained tokens → Revoke）。' -ForegroundColor Yellow
Write-Host '👉 再次确认仓库可见性是 Private。' -ForegroundColor Yellow
