# Скрипт оптимизации Windows с интерактивным меню
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Функция для проверки прав администратора
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Основные функции оптимизации из предыдущего скрипта
function Disable-UnecessaryServices {
    $servicesToDisable = @(
        "DiagTrack",           # Служба телеметрии
        "WerSvc",              # Служба отчетов об ошибках
        "PcaSvc",              # Служба помощника по совместимости программ
        "WSearch",             # Индексирование поиска
        "SysMain",             # Superfetch (prefetching)
        "MixedRealityOpenXRSvc" # Служба смешанной реальности
    )

    foreach ($service in $servicesToDisable) {
        try {
            Stop-Service -Name $service -Force
            Set-Service -Name $service -StartupType Disabled
            [System.Windows.Forms.MessageBox]::Show("Отключена служба: $service", "Информация", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Не удалось отключить службу: $service", "Ошибка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
}

function Set-PowerSettings {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change disk-timeout-ac 0
    [System.Windows.Forms.MessageBox]::Show("Настройки электропитания оптимизированы", "Успех", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Optimize-MouseSettings {
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x9E,0x1E,0x08,0x80,0x00,0x00,0x00,0x00))
    [System.Windows.Forms.MessageBox]::Show("Настройки мыши оптимизированы", "Успех", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Set-GamingGraphicsSettings {
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
    [System.Windows.Forms.MessageBox]::Show("Настройки графики для игр оптимизированы", "Успех", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Optimize-NetworkSettings {
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global timestamps=disabled
    netsh int tcp set global ecn=disabled
    netsh int tcp set global dca=enabled
    [System.Windows.Forms.MessageBox]::Show("Сетевые настройки оптимизированы", "Успех", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Clear-SystemCache {
    Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
    ipconfig /flushdns
    netsh winsock reset
    [System.Windows.Forms.MessageBox]::Show("Кэш и временные файлы очищены", "Успех", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Создание главной формы
function Show-OptimizationMenu {
    # Проверка прав администратора
    if (-not (Test-AdminRights)) {
        [System.Windows.Forms.MessageBox]::Show("Запустите скрипт от имени администратора!", "Ошибка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Создание главной формы
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Оптимизация Windows для игр"
    $form.Size = New-Object System.Drawing.Size(500, 600)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    # Заголовок
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Оптимизация Windows 11 для игр"
    $titleLabel.Location = New-Object System.Drawing.Point(50, 20)
    $titleLabel.Size = New-Object System.Drawing.Size(400, 40)
    $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($titleLabel)

    # Создание чекбоксов
    $checkBoxes = @{
        "Отключение служб" = $false
        "Настройки электропитания" = $false
        "Оптимизация мыши" = $false
        "Настройки графики" = $false
        "Оптимизация сети" = $false
        "Очистка кэша" = $false
    }

    $y = 100
    foreach ($key in $checkBoxes.Keys) {
        $checkBox = New-Object System.Windows.Forms.CheckBox
        $checkBox.Text = $key
        $checkBox.Location = New-Object System.Drawing.Point(50, $y)
        $checkBox.Size = New-Object System.Drawing.Size(400, 30)
        $checkBox.Checked = $false
        $form.Controls.Add($checkBox)

        # Привязка чекбокса к ключу
        $checkBoxes[$key] = $checkBox

        $y += 40
    }

    # Кнопка "Применить"
    $applyButton = New-Object System.Windows.Forms.Button
    $applyButton.Text = "Применить выбранные настройки"
    $applyButton.Location = New-Object System.Drawing.Point(50, $y + 30)
    $applyButton.Size = New-Object System.Drawing.Size(400, 50)
    $applyButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $applyButton.ForeColor = [System.Drawing.Color]::White
    $applyButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $applyButton.Add_Click({
        $actions = @{
            "Отключение служб" = ${function:Disable-UnecessaryServices}
            "Настройки электропитания" = ${function:Set-PowerSettings}
            "Оптимизация мыши" = ${function:Optimize-MouseSettings}
            "Настройки графики" = ${function:Set-GamingGraphicsSettings}
            "Оптимизация сети" = ${function:Optimize-NetworkSettings}
            "Очистка кэша" = ${function:Clear-SystemCache}
        }

        $selectedOptimizations = $actions.Keys | Where-Object { $checkBoxes[$_].Checked }

        if ($selectedOptimizations.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Выберите хотя бы одну оптимизацию", "Внимание", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $confirmResult = [System.Windows.Forms.MessageBox]::Show(
            "Вы уверены, что хотите применить выбранные оптимизации? Рекомендуется создать точку восстановления.",
            "Подтверждение",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($confirmResult -eq "Yes") {
            foreach ($optimization in $selectedOptimizations) {
                & $actions[$optimization]
            }

            $restartResult = [System.Windows.Forms.MessageBox]::Show(
                "Оптимизация завершена. Рекомендуется перезагрузка. Перезагрузить компьютер сейчас?",
                "Перезагрузка",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($restartResult -eq "Yes") {
                Restart-Computer -Force
            }
        }
    })
    $form.Controls.Add($applyButton)

    # Кнопка "Тест задержки мыши"
    $mouseTestButton = New-Object System.Windows.Forms.Button
    $mouseTestButton.Text = "Тест задержки мыши"
    $mouseTestButton.Location = New-Object System.Drawing.Point(50, $y + 100)
    $mouseTestButton.Size = New-Object System.Drawing.Size(400, 50)
    $mouseTestButton.BackColor = [System.Drawing.Color]::FromArgb(50, 205, 50)
    $mouseTestButton.ForeColor = [System.Drawing.Color]::White
    $mouseTestButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $mouseTestButton.Add_Click({
        $mouseTestForm = New-Object System.Windows.Forms.Form
        $mouseTestForm.Text = "Тест задержки мыши"
        $mouseTestForm.Size = New-Object System.Drawing.Size(400, 500)
        $mouseTestForm.StartPosition = "CenterScreen"

        $resultLabel = New-Object System.Windows.Forms.Label
        $resultLabel.Location = New-Object System.Drawing.Point(20, 20)
        $resultLabel.Size = New-Object System.Drawing.Size(350, 400)
        $resultLabel.Font = New-Object System.Drawing.Font("Consolas", 10)
        $mouseTestForm.Controls.Add($resultLabel)

        $startButton = New-Object System.Windows.Forms.Button
        $startButton.Text = "Начать тест"
        $startButton.Location = New-Object System.Drawing.Point(20, 430)
        $startButton.Size = New-Object System.Drawing.Size(350, 30)
        $startButton.Add_Click({
            $clickTimes = @()
            $resultLabel.Text = "Начните кликать как можно быстрее..." + [Environment]::NewLine

            # Замер времени
            $global:stopwatch = [System.Diagnostics.Stopwatch]::new()
            $mouseTestForm.KeyPreview = $true
            $mouseTestForm.Add_KeyDown({
                if ($clickTimes.Count -lt 30) {
                    $global:stopwatch.Restart()
                    $global:stopwatch.Start()
                }
            })
            $mouseTestForm.Add_KeyUp({
                if ($clickTimes.Count -lt 30) {
                    $global:stopwatch.Stop()
                    $latencyMs = $global:stopwatch.ElapsedMilliseconds
                    $clickTimes += $latencyMs

                    $resultLabel.Text += "Клик $($clickTimes.Count): $latencyMs мс" + [Environment]::NewLine

                    if ($clickTimes.Count -eq 30) {
                        $averageLatency = ($clickTimes | Measure-Object -Average).Average
                        $minLatency = ($clickTimes | Measure-Object -Minimum).Minimum
                        $maxLatency = ($clickTimes | Measure-Object -Maximum).Maximum

                        $resultLabel.Text += [Environment]::NewLine + "===== РЕЗУЛЬТАТЫ =====" + [Environment]::NewLine
                        $resultLabel.Text += "Средняя задержка: $($averageLatency.ToString('N2')) мс" + [Environment]::NewLine
                        $resultLabel.Text += "Минимальная задержка: $minLatency мс" + [Environment]::NewLine
                        $resultLabel.Text += "Максимальная задержка: $maxLatency мс"
                    }
                }
            })
        })
        $mouseTestForm.Controls.Add($startButton)

        $mouseTestForm.ShowDialog()
    })
    $form.Controls.Add($mouseTestButton)

    # Предупреждение
    $warningLabel = New-Object System.Windows.Forms.Label
    $warningLabel.Text = "Внимание: Создайте точку восстановления перед оптимизацией!"
    $warningLabel.Location = New-Object System.Drawing.Point(50, $y + 170)
    $warningLabel.Size = New-Object System.Drawing.Size(400, 30)
    $warningLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $warningLabel.ForeColor = [System.Drawing.Color]::Red
    $warningLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($warningLabel)

    # Добавление кнопки создания точки восстановления
    $restorePointButton = New-Object System.Windows.Forms.Button
    $restorePointButton.Text = "Создать точку восстановления"
    $restorePointButton.Location = New-Object System.Drawing.Point(50, $y + 210)
    $restorePointButton.Size = New-Object System.Drawing.Size(400, 50)
    $restorePointButton.BackColor = [System.Drawing.Color]::FromArgb(255, 165, 0)
    $restorePointButton.ForeColor = [System.Drawing.Color]::White
    $restorePointButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $restorePointButton.Add_Click({
        try {
            # Создание точки восстановления
            $description = "Точка восстановления перед оптимизацией Windows - " + (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")
            $result = Checkpoint-Computer -Description $description -ErrorAction Stop

            [System.Windows.Forms.MessageBox]::Show(
                "Точка восстановления успешно создана:`n$description",
                "Успех",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Не удалось создать точку восстановления. Ошибка: $($_.Exception.Message)",
                "Ошибка",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })
    $form.Controls.Add($restorePointButton)

    # Функция для проверки и подготовки системы к оптимизации
    function Prepare-SystemForOptimization {
        # Отключение защитника Windows перед оптимизацией
        Set-MpPreference -DisableRealtimeMonitoring $true

        # Очистка папки temp
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

        # Освобождение места на диске
        Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
    }

    # Функция восстановления системных настроек
    function Restore-SystemSettings {
        # Включение защитника Windows
        Set-MpPreference -DisableRealtimeMonitoring $false

        # Возврат служб к настройкам по умолчанию
        $servicesToRestore = @(
            "DiagTrack",
            "WerSvc",
            "PcaSvc",
            "WSearch",
            "SysMain",
            "MixedRealityOpenXRSvc"
        )

        foreach ($service in $servicesToRestore) {
            try {
                Set-Service -Name $service -StartupType Automatic
                Start-Service -Name $service
            }
            catch {}
        }
    }

    # Кнопка восстановления системы
    $restoreSystemButton = New-Object System.Windows.Forms.Button
    $restoreSystemButton.Text = "Восстановить системные настройки"
    $restoreSystemButton.Location = New-Object System.Drawing.Point(50, $y + 270)
    $restoreSystemButton.Size = New-Object System.Drawing.Size(400, 50)
    $restoreSystemButton.BackColor = [System.Drawing.Color]::FromArgb(220, 20, 60)
    $restoreSystemButton.ForeColor = [System.Drawing.Color]::White
    $restoreSystemButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $restoreSystemButton.Add_Click({
        $confirmResult = [System.Windows.Forms.MessageBox]::Show(
            "Вы уверены, что хотите восстановить системные настройки по умолчанию?",
            "Подтверждение",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($confirmResult -eq "Yes") {
            try {
                Restore-SystemSettings
                [System.Windows.Forms.MessageBox]::Show(
                    "Системные настройки восстановлены",
                    "Успех",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Ошибка восстановления: $($_.Exception.Message)",
                    "Ошибка",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        }
    })
    $form.Controls.Add($restoreSystemButton)

    # Показ формы
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog()
}

# Запуск главного меню
Show-OptimizationMenu
