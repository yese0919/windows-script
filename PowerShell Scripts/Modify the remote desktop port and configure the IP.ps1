# 设置默认的 RDP 端口号为 3389
$rdp_port = Read-Host "请输入RDP端口号（默认3389）"
if ($rdp_port -eq "") {
    $rdp_port = 3389
}

# 获取当前 RDP 端口号
$current_rdp_port = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" | Select-Object -ExpandProperty PortNumber

Write-Host "当前RDP端口号为: $current_rdp_port"

# 如果当前端口号与输入端口号不同，则修改
if ($current_rdp_port -ne $rdp_port) {
    Write-Host "修改RDP端口为: $rdp_port"

    # 修改注册表以设置 RDP 端口
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -Value $rdp_port

    # 添加防火墙规则以允许新的 RDP 端口
    New-NetFirewallRule -DisplayName "Allow RDP on port $rdp_port" -Protocol TCP -LocalPort $rdp_port -Direction Inbound -Action Allow
} else {
    Write-Host "RDP端口已是 $rdp_port，无需修改。"
}

# 获取所有网卡及其 MAC 地址
$interfaces = Get-NetAdapter | Select-Object Name, MacAddress

# 输出网卡列表并手动添加序号
Write-Host "可用网卡列表："
$index = 1
$interfaces | ForEach-Object {
    Write-Host "$index. $($_.Name) - $($_.MacAddress)"
    $index++
}

# 让用户选择网卡
$selectedIndex = Read-Host "请输入网卡的序号（例如：1）"

# 获取选定的网卡
$interface = $interfaces[$selectedIndex - 1]  # 由于数组索引从0开始，减去1

# 确保网卡有效
if ($interface -eq $null) {
    Write-Host "无效的选择，请重新运行脚本。"
    exit
}

Write-Host "已选择网卡：$($interface.Name) - $($interface.MacAddress)"

# 获取网卡的 InterfaceIndex
$interfaceIndex = (Get-NetAdapter -Name $interface.Name).ifIndex

# 确保 InterfaceIndex 有效
if ($interfaceIndex -eq $null -or $interfaceIndex -eq 0) {
    Write-Host "无法获取网卡的 InterfaceIndex，退出脚本。"
    exit
}

# 输入 IP 地址、子网掩码、网关和 DNS 服务器
$ip_address = Read-Host "请输入静态 IP 地址（例如：10.10.10.121）"
$subnet_mask = Read-Host "请输入子网掩码（例如：255.255.255.0）"
$gateway = Read-Host "请输入默认网关（例如：10.10.10.1）(可选)"

# 输入 DNS 服务器
$primary_dns = Read-Host "请输入主 DNS 服务器（例如：192.168.3.254）"
$secondary_dns = Read-Host "请输入备用 DNS 服务器（例如：119.29.29.29）"

# 检查当前网卡是否已配置相同的 IP 地址
$existingIp = Get-NetIPAddress -InterfaceIndex $interfaceIndex | Where-Object { $_.IPAddress -eq $ip_address }

if ($existingIp) {
    Write-Host "IP 地址 $ip_address 已经配置在该网卡上，跳过添加 IP 地址。"
} else {
    # 如果用户提供了网关，才设置网关
    if ($gateway) {
        # 设置静态 IP 地址和网关
        New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip_address -PrefixLength 24 -DefaultGateway $gateway
        Write-Host "IP 地址 $ip_address 和网关 $gateway 已成功配置到网卡 $($interface.Name)。"
    } else {
        # 仅设置静态 IP 地址
        New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip_address -PrefixLength 24
        Write-Host "IP 地址 $ip_address 已成功配置到网卡 $($interface.Name)。"
    }
}

# 设置 DNS 服务器
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses $primary_dns,$secondary_dns

# 可选：立即重启（如果需要）
# Restart-Computer -Force

Write-Host "配置完成！"
