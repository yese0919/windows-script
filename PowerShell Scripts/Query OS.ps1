# 手动输入服务器名，逗号分隔
$inputStr = Read-Host "请输入服务器名称或IP（多个以英文逗号分隔，例如 server1,192.168.1.100）"
$servers = $inputStr.Split(',') | ForEach-Object { $_.Trim() }

# 输入凭据
$cred = Get-Credential

foreach ($server in $servers) {
    Write-Host "正在查询 $server 的操作系统版本..." -ForegroundColor Cyan
    try {
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server -Credential $cred
        Write-Host "[$server] $($os.Caption) - $($os.Version) - $($os.OSArchitecture)" -ForegroundColor Green
    } catch {
        Write-Host "无法连接到 $server：$_" -ForegroundColor Red
    }
}
