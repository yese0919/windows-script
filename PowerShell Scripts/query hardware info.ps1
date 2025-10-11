# 品牌与型号
$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$manufacturer = $computerSystem.Manufacturer
$model = $computerSystem.Model

# 序列号
$serial = Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber

# CPU 信息
$cpuList = Get-CimInstance -ClassName Win32_Processor

# 物理内存条信息
$memoryModules = Get-CimInstance -ClassName Win32_PhysicalMemory
$memoryCount = $memoryModules.Count

# 总物理内存
$totalMemory = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)

# 逻辑内存（系统视角）
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$totalVirtualMemory = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeVirtualMemory  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedVirtualMemory  = [math]::Round($totalVirtualMemory - $freeVirtualMemory, 2)

# 输出信息
Write-Host "======== 系统硬件信息 ========"
Write-Host "品牌厂商       : $manufacturer"
Write-Host "机器型号       : $model"
Write-Host "序列号(SN)     : $serial"
Write-Host ""

foreach ($cpu in $cpuList) {
    Write-Host "CPU 名称       : $($cpu.Name)"
    Write-Host "核心数（物理） : $($cpu.NumberOfCores)"
    Write-Host "线程数（逻辑） : $($cpu.NumberOfLogicalProcessors)"
    Write-Host "插槽编号       : $($cpu.SocketDesignation)"
    Write-Host ""
}

Write-Host "物理内存条数   : $memoryCount"
Write-Host "总物理内存     : $totalMemory GB"
Write-Host ""

foreach ($mem in $memoryModules) {
    $memSizeGB = [math]::Round($mem.Capacity / 1GB, 2)
    Write-Host "内存条插槽     : $($mem.DeviceLocator)"
    Write-Host "  容量         : $memSizeGB GB"
    Write-Host "  频率         : $($mem.Speed) MHz"
    Write-Host "  制造商       : $($mem.Manufacturer)"
    Write-Host ""
}

Write-Host "======== 系统内存使用情况 ========"
Write-Host "逻辑内存总量   : $totalVirtualMemory GB"
Write-Host "可用内存       : $freeVirtualMemory GB"
Write-Host "已用内存       : $usedVirtualMemory GB"
