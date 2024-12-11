# Расширенный скрипт оптимизации Windows 11 для игр с расширенными настройками производительности
# ВАЖНО: Запускайте от имени администратора с правами PowerShell

# Функция для логирования действий
function Write-OptimizationLog {
    param([string]$Message)
    Write-Host "[ОПТИМИЗАЦИЯ] $Message" -ForegroundColor Green
}

# Функция расширенной сетевой оптимизации
function Optimize-AdvancedNetworkSettings {
    Write-OptimizationLog "Расширенная оптимизация сетевых настроек"
    
    # Настройка динамических портов с увеличенным диапазоном
    netsh int ipv4 set dynamicport tcp start=1024 num=64512
    netsh int ipv4 set dynamicport udp start=1024 num=64512
    
    # Отключение unnecessary сетевых протоколов
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_lltdio
    
    # Оптимизация TCP параметров для игр
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SynAttackProtect" /t REG_DWORD /d 1 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 1 /f
    
    # Настройки сетевой карты для снижения задержек
    Get-NetAdapter | ForEach-Object {
        # Отключение энергосбережения для сетевых адаптеров
        Disable-NetAdapterPowerManagement -Name $_.Name
        
        # Настройка прерываний и RSS
        Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Receive Side Scaling" -DisplayValue "Enabled"
        Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "*RSS" -DisplayValue "Enabled"
        Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "*NumRssQueues" -DisplayValue "4"
    }
    
    # Отключение автоматического определения прокси
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "ProxyEnable" /t REG_DWORD /d 0 /f
}

# Расширенная функция отключения служб
function Disable-AdvancedServices {
    Write-OptimizationLog "Расширенное отключение системных служб"
    
    $servicesToDisable = @(
        "DiagTrack",           # Служба телеметрии
        "WSearch",             # Служба поиска Windows
        "WerSvc",              # Служба отчетов об ошибках
        "PcaSvc",              # Служба диагностики производительности
        "WMPNetworkSvc",       # Служба общего доступа к мультимедиа
        "PeerDistSvc",         # Служба распределенного кэширования
        "WbioSrvc",            # Служба биометрических данных
        "MapsBroker",          # Служба загрузки карт
        "lfsvc",               # Служба геолокации
        "AdobeARMservice",     # Служба обновлений Adobe
        "NetTcpPortSharing",   # Служба общего доступа к портам
        "RemoteRegistry",      # Удаленный реестр
        "SharedAccess",        # Служба брандмауэра
        "PhoneSvc",            # Служба телефонии
        "SysMain",             # Служба SuperFetch
        "TrkWks",              # Служба связи рабочих станций
        "WdiServiceHost",      # Диагностический хост службы
        "WdiSystemService",    # Диагностическая системная служба
        "MixedRealityOpenXRSvc" # Служба смешанной реальности
    )
    
    foreach ($service in $servicesToDisable) {
        try {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Служба $service отключена" -ForegroundColor Yellow
        }
        catch {
            Write-Host "Не удалось отключить службу: $service" -ForegroundColor Red
        }
    }
}

# Функция оптимизации процессора и приоритетов
function Optimize-ProcessorSettings {
    Write-OptimizationLog "Оптимизация настроек процессора"
    
    # Настройка приоритетов процессора для игр
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 42 /f
    
    # Отключение функций энергосбережения
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
    
    # Настройка максимальной производительности ЦП
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v "ValueMin" /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v "ValueMax" /t REG_DWORD /d 100 /f
}

# Функция глубокой очистки системы
function Clear-DeepSystemOptimization {
    Write-OptimizationLog "Глубокая очистка системы"
    
    # Расширенная очистка временных файлов
    try {
        # Очистка системных временных папок
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$env:USERNAME\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Очистка кэша браузеров
        Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:APPDATA\..\Local\Mozilla\Firefox\Profiles\*\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Очистка кэша Windows
        Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
        
        # Очистка корзины и загрузок
        Clear-RecycleBin -Force
        Remove-Item -Path "$env:USERPROFILE\Downloads\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Запуск расширенной очистки диска
        Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
    }
    catch {
        Write-Host "Ошибка при глубокой очистке системы" -ForegroundColor Red
    }
}

# Функция оптимизации графического интерфейса
function Optimize-UIPerformance {
    Write-OptimizationLog "Оптимизация графического интерфейса"
    
    # Отключение визуальных эффектов
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f
    
    # Отключение анимации
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
    
    # Настройки прозрачности и теней
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f
    
    # Отключение фоновых эффектов
    reg add "HKCU\Control Panel\Desktop" /v "UserPreferenceMask" /t REG_BINARY /d 9012038010000000 /f
}

# Функция теста латентности
function Test-InputLatency { 
    param( [string]$DeviceType = "All" ) 
    
    $mouseLatency = @() 
    $keyboardLatency = @() 
    
    if ($DeviceType -eq "Mouse" -or $DeviceType -eq "All") { 
        Write-Host "Measuring mouse input latency..." -ForegroundColor Cyan 
        for ($i = 0; $i -lt 10; $i++) { 
            $start = Get-Date 
            Add-Type -AssemblyName System.Windows.Forms 
            [System.Windows.Forms.Cursor]::Position 
            $end = Get-Date 
            $latency = ($end - $start).TotalMilliseconds 
            $mouseLatency += $latency 
        } 
        $mouseAvg = $mouseLatency | Measure-Object -Average 
        Write-Host "Mouse Latency Results:" -ForegroundColor Green 
        Write-Host "Average: $($mouseAvg.Average) ms" -ForegroundColor Yellow 
        Write-Host "Min: $($mouseLatency | Measure-Object -Minimum).Minimum ms" -ForegroundColor Yellow 
        Write-Host "Max: $($mouseLatency | Measure-Object -Maximum).Maximum ms" -ForegroundColor Yellow 
    } 
    
    if ($DeviceType -eq "Keyboard" -or $DeviceType -eq "All") { 
        Write-Host "`nMeasuring keyboard input latency..." -ForegroundColor Cyan 
        for ($i = 0; $i -lt 10; $i++) { 
            $start = Get-Date 
            Add-Type -AssemblyName System.Windows.Forms 
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") 
            $end = Get-Date 
            $latency = ($end - $start).TotalMilliseconds 
            $keyboardLatency += $latency 
        } 
        $keyboardAvg = $keyboardLatency | Measure-Object -Average 
        Write-Host "Keyboard Latency Results:" -ForegroundColor Green 
        Write-Host "Average: $($keyboardAvg.Average) ms" -ForegroundColor Yellow 
        Write-Host "Min: $($keyboardLatency | Measure-Object -Minimum).Minimum ms" -ForegroundColor Yellow 
        Write-Host "Max: $($keyboardLatency | Measure-Object -Maximum).Maximum ms" -ForegroundColor Yellow 
    } 
} 

# Главная функция полной оптимизации
function Optimize-UltimateGamingPerformance {
    Write-Host "====== НАЧАЛО РАСШИРЕННОЙ ОПТИМИЗАЦИИ WINDOWS ДЛЯ ИГР ======" -ForegroundColor Magenta
    
    Optimize-ProcessorSettings
    Optimize-AdvancedNetworkSettings
    Disable-AdvancedServices
    Optimize-UIPerformance
    Clear-DeepSystemOptimization
    
    Write-Host "====== ОПТИМИЗАЦИЯ ЗАВЕРШЕНА ======" -ForegroundColor Magenta
    Write-Host "Рекомендуется перезагрузка компьютера" -ForegroundColor Yellow
}

# Дополнительные рекомендации после оптимизации
function Show-UltimateOptimizationTips {
    Write-Host "`nДополнительные рекомендации для максимальной производительности:" -ForegroundColor Cyan
    Write-Host "1. Обновите драйверы графической карты до последней версии" -ForegroundColor Green
    Write-Host "2. Отключите антивирус на время игры" -ForegroundColor Green
    Write-Host "3. Закройте все фоновые приложения" -ForegroundColor Green
    Write-Host "4. Проверьте и оптимизируйте настройки графической карты" -ForegroundColor Green
    Write-Host "5. Используйте Game Mode в Windows" -ForegroundColor Green
    Write-Host "6. Отключите оверлеи и записи игр" -ForegroundColor Green
    Write-Host "7. Установите последние обновления DirectX" -ForegroundColor Green
}

# Меню выбора действий
function Show-MainMenu {
    Clear-Host
    Write-Host "====== РАСШИРЕННАЯ ОПТИМИЗАЦИЯ WINDOWS ДЛЯ ИГР ======" -ForegroundColor Magenta
    Write-Host "1. Полная оптимизация системы" -ForegroundColor Green
    Write-Host "2. Проверка латентности устройств" -ForegroundColor Cyan
    Write-Host "3. Отдельные настройки оптимизации" -ForegroundColor Yellow
    Write-Host "4. Выход" -ForegroundColor Red
    Write-Host "`nВыберите действие (1-4):" -ForegroundColor White
}

# Подменю настроек оптимизации
function Show-OptimizationSubMenu {
    Clear-Host
    Write-Host "====== НАСТРОЙКИ ОПТИМИЗАЦИИ ======" -ForegroundColor Magenta
    Write-Host "1. Оптимизация настроек процессора" -ForegroundColor Green
    Write-Host "2. Оптимизация сетевых настроек" -ForegroundColor Cyan
    Write-Host "3. Отключение системных служб" -ForegroundColor Yellow
    Write-Host "4. Оптимизация графического интерфейса" -ForegroundColor Blue
    Write-Host "5. Глубокая очистка системы" -ForegroundColor Red
    Write-Host "6. Назад в главное меню" -ForegroundColor White
    Write-Host "`nВыберите действие (1-6):" -ForegroundColor White
}

# Подменю проверки латентности
function Show-LatencySubMenu {
    Clear-Host
    Write-Host "====== ПРОВЕРКА ЛАТЕНТНОСТИ УСТРОЙСТВ ======" -ForegroundColor Magenta
    Write-Host "1. Проверка латентности мыши" -ForegroundColor Green
    Write-Host "2. Проверка латентности клавиатуры" -ForegroundColor Cyan
    Write-Host "3. Проверка латентности всех устройств" -ForegroundColor Yellow
    Write-Host "4. Назад в главное меню" -ForegroundColor Red
    Write-Host "`nВыберите действие (1-4):" -ForegroundColor White
}

# Основная функция управления меню
function Start-OptimizationMenu {
    do {
        Show-MainMenu
        $choice = Read-Host "Введите номер действия"
        
        switch ($choice) {
            '1' { 
                Clear-Host
                Optimize-UltimateGamingPerformance
                Show-UltimateOptimizationTips
                Read-Host "Нажмите Enter для возврата в меню..."
            }
            '2' { 
                do {
                    Show-LatencySubMenu
                    $latencyChoice = Read-Host "Введите номер действия"
                    
                    switch ($latencyChoice) {
                        '1' { 
                            Test-InputLatency -DeviceType "Mouse" 
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '2' { 
                            Test-InputLatency -DeviceType "Keyboard" 
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '3' { 
                            Test-InputLatency -DeviceType "All" 
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '4' { break }
                        default { 
                            Write-Host "Неверный выбор. Попробуйте снова." -ForegroundColor Red 
                            Start-Sleep -Seconds 2
                        }
                    }
                } while ($latencyChoice -ne '4')
            }
            '3' { 
                do {
                    Show-OptimizationSubMenu
                    $optimizationChoice = Read-Host "Введите номер действия"
                    
                    switch ($optimizationChoice) {
                        '1' { 
                            Optimize-ProcessorSettings
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '2' { 
                            Optimize-AdvancedNetworkSettings
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '3' { 
                            Disable-AdvancedServices
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '4' { 
                            Optimize-UIPerformance
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '5' { 
                            Clear-DeepSystemOptimization
                            Read-Host "Нажмите Enter для продолжения..."
                        }
                        '6' { break }
                        default { 
                            Write-Host "Неверный выбор. Попробуйте снова." -ForegroundColor Red 
                            Start-Sleep -Seconds 2
                        }
                    }
                } while ($optimizationChoice -ne '6')
            }
            '4' { 
                Write-Host "Выход из программы..." -ForegroundColor Red
                return 
            }
            default { 
                Write-Host "Неверный выбор. Попробуйте снова." -ForegroundColor Red 
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

# Добавление функции проверки прав администратора
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    return (New-Object Security.Principal.WindowsPrincipal($currentUser)).IsInRole($adminRole)
}

# Главная точка входа скрипта
function Main {
    # Проверка прав администратора
    if (-not (Test-AdminRights)) {
        Write-Host "ОШИБКА: Скрипт должен быть запущен от имени администратора!" -ForegroundColor Red
        Write-Host "Пожалуйста, запустите PowerShell от имени администратора" -ForegroundColor Yellow
        Read-Host "Нажмите Enter для выхода..."
        return
    }

    # Вывод предупреждения
    Write-Host "ВНИМАНИЕ: Использование этого скрипта осуществляется на ваш страх и риск!" -ForegroundColor Red
    Write-Host "Перед применением настоятельно рекомендуется создать резервную копию системы." -ForegroundColor Yellow
    $confirm = Read-Host "Вы подтверждаете, что ознакомлены с предупреждением? (Да/Нет)"
    
    if ($confirm.ToLower() -eq "да") {
        # Запуск основного меню
        Start-OptimizationMenu
    }
    else {
        Write-Host "Выполнение скрипта отменено." -ForegroundColor Red
    }
}

# Запуск основной функции
Main
