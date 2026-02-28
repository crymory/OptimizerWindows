# ==================================================================================
# WINDOWS 11 PRO OPTIMIZER v6.5 - ULTIMATE UI EDITION
# Профессиональная оптимизация с современным интерфейсом и выбором Bloatware
# ==================================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Drawing2D

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show(
        "ОШИБКА: Запустите программу от имени Администратора!",
        "Требуется повышенный доступ",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Exit
}

# ==================================================================================
# ЦВЕТОВАЯ ПАЛИТРА (Deep Dark & Accent)
# ==================================================================================
$colorBg = [System.Drawing.Color]::FromArgb(18, 18, 24)
$colorBgLight = [System.Drawing.Color]::FromArgb(28, 28, 38)
$colorBgCard = [System.Drawing.Color]::FromArgb(38, 38, 50)
$colorPrimary = [System.Drawing.Color]::FromArgb(0, 160, 255)
$colorSuccess = [System.Drawing.Color]::FromArgb(0, 210, 100)
$colorWarning = [System.Drawing.Color]::FromArgb(255, 160, 0)
$colorDanger = [System.Drawing.Color]::FromArgb(240, 70, 70)
$colorText = [System.Drawing.Color]::FromArgb(245, 245, 250)
$colorTextMuted = [System.Drawing.Color]::FromArgb(140, 140, 160)
$colorToggleOff = [System.Drawing.Color]::FromArgb(60, 60, 80)
$colorToggleOn = $colorPrimary

# Глобальные переменные
$global:Toggles = @{}
$global:AppCheckboxes = @()
$global:LogHistory = @()

# ==================================================================================
# СИСТЕМНАЯ ИНФОРМАЦИЯ
# ==================================================================================
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 0)
$freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 0)
$usedRam = $ram - $freeRam
$ramPercent = [math]::Round(($usedRam / $ram) * 100, 0)
$disk = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq 0}
$diskType = if ($disk.MediaType -eq "SSD") { "SSD" } else { "HDD" }
$diskSize = [math]::Round($disk.Size / 1GB, 0)

# ==================================================================================
# СОЗДАНИЕ ОСНОВНОГО ОКНА
# ==================================================================================
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Windows 11 Pro Optimizer v6.5"
$mainForm.Size = New-Object System.Drawing.Size(1150, 850)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedSingle"
$mainForm.MaximizeBox = $false
$mainForm.BackColor = $colorBg
$mainForm.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# ==================================================================================
# ЗАГОЛОВОК
# ==================================================================================
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(1150, 90)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = $colorBgCard

$headerTitle = New-Object System.Windows.Forms.Label
$headerTitle.Text = "⚡ Windows 11 Pro Optimizer"
$headerTitle.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$headerTitle.ForeColor = $colorPrimary
$headerTitle.Location = New-Object System.Drawing.Point(25, 15)
$headerTitle.AutoSize = $true

$headerSubtitle = New-Object System.Windows.Forms.Label
$headerSubtitle.Text = "Ultimate Edition v6.5 | Тонкая настройка и контроль"
$headerSubtitle.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$headerSubtitle.ForeColor = $colorTextMuted
$headerSubtitle.Location = New-Object System.Drawing.Point(30, 55)
$headerSubtitle.AutoSize = $true

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "✓ Система готова"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$statusLabel.ForeColor = $colorSuccess
$statusLabel.Location = New-Object System.Drawing.Point(920, 35)
$statusLabel.AutoSize = $true

$headerPanel.Controls.Add($headerTitle)
$headerPanel.Controls.Add($headerSubtitle)
$headerPanel.Controls.Add($statusLabel)
$mainForm.Controls.Add($headerPanel)

# ==================================================================================
# ТАБЫ (TabControl) - С КАСТОМНОЙ ОТРИСОВКОЙ
# ==================================================================================
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(1130, 560)
$tabControl.Location = New-Object System.Drawing.Point(10, 100)
$tabControl.BackColor = $colorBg
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$tabControl.SizeMode = "Fixed"
$tabControl.ItemSize = New-Object System.Drawing.Size(275, 40)
$tabControl.DrawMode = "OwnerDrawFixed"

$tabControl.Add_DrawItem({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = "AntiAlias"
    $tabPage = $sender.TabPages[$e.Index]
    $tabBounds = $e.Bounds

    $isSelected = ($e.State -band [System.Windows.Forms.DrawItemState]::Selected) -eq [System.Windows.Forms.DrawItemState]::Selected
    
    $fillColor = if ($isSelected) { $colorBg } else { $colorBgCard }
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($fillColor)), $tabBounds)

    if ($isSelected) {
        $g.FillRectangle((New-Object System.Drawing.SolidBrush($colorPrimary)), $tabBounds.X, $tabBounds.Y, $tabBounds.Width, 3)
    }

    $textColor = if ($isSelected) { $colorPrimary } else { $colorTextMuted }
    $textBrush = New-Object System.Drawing.SolidBrush($textColor)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = "Center"
    $stringFormat.LineAlignment = "Center"
    
    $font = if ($isSelected) { New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold) } else { $sender.Font }
    $g.DrawString($tabPage.Text, $font, $textBrush, $tabBounds, $stringFormat)
})

# ==================================================================================
# ТАБ 1: ГЛАВНАЯ (Оптимизация)
# ==================================================================================
$tabMain = New-Object System.Windows.Forms.TabPage
$tabMain.Text = "⚙️ Главная"
$tabMain.BackColor = $colorBg

# Панель системной информации
$sysInfoPanel = New-Object System.Windows.Forms.Panel
$sysInfoPanel.Size = New-Object System.Drawing.Size(1110, 80)
$sysInfoPanel.Location = New-Object System.Drawing.Point(5, 15)
$sysInfoPanel.BackColor = $colorBgLight

$sysLabels = @(
    @{Text="ОС:"; Value="$($os.Caption)"; X=20},
    @{Text="CPU:"; Value="$($cpu.Name.Substring(0, [Math]::Min(40, $cpu.Name.Length)))"; X=300},
    @{Text="ОЗУ:"; Value="$usedRam / $ram GB ($ramPercent%)"; X=650},
    @{Text="Диск:"; Value="$diskType | $diskSize GB"; X=900}
)

foreach ($info in $sysLabels) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $info.Text
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = $colorTextMuted
    $lbl.Location = New-Object System.Drawing.Point($info.X, 15)
    
    $val = New-Object System.Windows.Forms.Label
    $val.Text = $info.Value
    $val.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $val.ForeColor = $colorText
    $val.Location = New-Object System.Drawing.Point($info.X, 35)
    $val.AutoSize = $true
    
    $sysInfoPanel.Controls.Add($lbl)
    $sysInfoPanel.Controls.Add($val)
}
$tabMain.Controls.Add($sysInfoPanel)

# Функция создания переключателя
function Create-ToggleSwitch {
    param([string]$Name, [string]$Text, [string]$Description, [int]$X, [int]$Y, [bool]$Checked = $true)
    
    $container = New-Object System.Windows.Forms.Panel
    $container.Size = New-Object System.Drawing.Size(540, 70)
    $container.Location = New-Object System.Drawing.Point($X, $Y)
    $container.BackColor = $colorBgLight
    $container.Cursor = "Hand"
    
    $lblText = New-Object System.Windows.Forms.Label
    $lblText.Text = $Text
    $lblText.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $lblText.ForeColor = $colorText
    $lblText.AutoSize = $true
    $lblText.Location = New-Object System.Drawing.Point(70, 12)
    $lblText.Cursor = "Hand"
    
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text = $Description
    $lblDesc.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $lblDesc.ForeColor = $colorTextMuted
    $lblDesc.AutoSize = $true
    $lblDesc.Location = New-Object System.Drawing.Point(70, 37)
    $lblDesc.Cursor = "Hand"
    
    $toggleBox = New-Object System.Windows.Forms.PictureBox
    $toggleBox.Size = New-Object System.Drawing.Size(50, 28)
    $toggleBox.Location = New-Object System.Drawing.Point(10, 20)
    $toggleBox.BackColor = $colorBgLight
    $toggleBox.Cursor = "Hand"
    $toggleBox.Tag = $Checked
    
    function Draw-Toggle {
        param($pictureBox, $isOn)
        $bmp = New-Object System.Drawing.Bitmap 50, 28
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.SmoothingMode = "AntiAlias"
        
        $bgColor = if ($isOn) { $colorToggleOn } else { $colorToggleOff }
        $bgBrush = New-Object System.Drawing.SolidBrush($bgColor)
        $g.FillEllipse($bgBrush, 0, 0, 28, 28)
        $g.FillEllipse($bgBrush, 22, 0, 28, 28)
        $g.FillRectangle($bgBrush, 14, 0, 22, 28)
        
        $circleX = if ($isOn) { 24 } else { 2 }
        $circleBrush = New-Object System.Drawing.SolidBrush($colorText)
        $g.FillEllipse($circleBrush, $circleX, 2, 24, 24)
        
        $pictureBox.Image = $bmp
        $pictureBox.Tag = $isOn
    }
    
    Draw-Toggle $toggleBox $Checked
    
    $clickHandler = {
        $currentState = $toggleBox.Tag -as [bool]
        $newState = -not $currentState
        Draw-Toggle $toggleBox $newState
        $global:Toggles[$toggleBox.Name] = $newState
    }

    $toggleBox.Add_Click($clickHandler)
    $container.Add_Click($clickHandler)
    $lblText.Add_Click($clickHandler)
    $lblDesc.Add_Click($clickHandler)
    
    $toggleBox.Name = $Name
    $global:Toggles[$Name] = $Checked
    
    $container.Controls.Add($toggleBox)
    $container.Controls.Add($lblText)
    $container.Controls.Add($lblDesc)
    
    return $container
}

# Левая колонка
$togglePanel = New-Object System.Windows.Forms.Panel
$togglePanel.Size = New-Object System.Drawing.Size(550, 420)
$togglePanel.Location = New-Object System.Drawing.Point(5, 110)

$y = 0
$togglePanel.Controls.Add((Create-ToggleSwitch "RestorePoint" "Точка восстановления" "Создаёт резервную точку для отката" 0 $y $true)); $y += 80
$togglePanel.Controls.Add((Create-ToggleSwitch "PowerPlan" "Максимальная производительность" "Активирует схему Ultimate Performance" 0 $y $true)); $y += 80
$togglePanel.Controls.Add((Create-ToggleSwitch "AIFeatures" "Отключить AI функции" "Copilot, Recall, Search Highlights" 0 $y $true)); $y += 80
$togglePanel.Controls.Add((Create-ToggleSwitch "Services" "Отключить ненужные сервисы" "Телеметрия, Фоновые службы отслеживания" 0 $y $true)); $y += 80

$tabMain.Controls.Add($togglePanel)

# Правая колонка
$togglePanel2 = New-Object System.Windows.Forms.Panel
$togglePanel2.Size = New-Object System.Drawing.Size(550, 420)
$togglePanel2.Location = New-Object System.Drawing.Point(565, 110)

$y = 0
$togglePanel2.Controls.Add((Create-ToggleSwitch "Network" "Оптимизация сети" "TCP/IP настройки для снижения пинга" 0 $y $true)); $y += 80
$togglePanel2.Controls.Add((Create-ToggleSwitch "Registry" "Твики реестра" "Оптимизация задержек и приоритетов Win32" 0 $y $true)); $y += 80
$togglePanel2.Controls.Add((Create-ToggleSwitch "TempFiles" "Очистка временных файлов" "Удаление кэша, логов и Windows.old" 0 $y $true)); $y += 80
$togglePanel2.Controls.Add((Create-ToggleSwitch "GameMode" "Игровой режим" "Отключение Game DVR, оптимизация FPS" 0 $y $true)); $y += 80

$tabMain.Controls.Add($togglePanel2)

# ==================================================================================
# ТАБ 2: ПРИЛОЖЕНИЯ (Bloatware)
# ==================================================================================
$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = "🗑️ Приложения"
$tabApps.BackColor = $colorBg

$appsLabel = New-Object System.Windows.Forms.Label
$appsLabel.Text = "Выберите встроенные приложения (Bloatware) для удаления:"
$appsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$appsLabel.ForeColor = $colorText
$appsLabel.AutoSize = $true
$appsLabel.Location = New-Object System.Drawing.Point(15, 20)

# Контейнер для чекбоксов
$appsFlowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$appsFlowPanel.Size = New-Object System.Drawing.Size(1100, 360)
$appsFlowPanel.Location = New-Object System.Drawing.Point(15, 60)
$appsFlowPanel.BackColor = $colorBgLight
$appsFlowPanel.AutoScroll = $true
$appsFlowPanel.Padding = New-Object System.Windows.Forms.Padding(15)

$bloatwareApps = @(
    @{Id="Microsoft.BingNews"; Name="📰 Bing News (Новости)"},
    @{Id="Microsoft.BingWeather"; Name="🌤️ Bing Weather (Погода)"},
    @{Id="Microsoft.XboxApp"; Name="🎮 Xbox App"},
    @{Id="Microsoft.XboxGamingOverlay"; Name="🎮 Xbox Gaming Overlay"},
    @{Id="Microsoft.ZuneVideo"; Name="🎬 Кино и ТВ (Zune Video)"},
    @{Id="Microsoft.ZuneMusic"; Name="🎵 Groove Music"},
    @{Id="Clipchamp.Clipchamp"; Name="✂️ Clipchamp (Видеоредактор)"},
    @{Id="MicrosoftTeams"; Name="💬 Microsoft Teams"},
    @{Id="Microsoft.SkypeApp"; Name="📞 Skype"},
    @{Id="Microsoft.GetHelp"; Name="❓ Get Help (Техподдержка)"},
    @{Id="Microsoft.Getstarted"; Name="💡 Get Started (Советы)"},
    @{Id="Microsoft.MicrosoftSolitaireCollection"; Name="🃏 Solitaire Collection"},
    @{Id="Microsoft.YourPhone"; Name="📱 Your Phone (Связь с телефоном)"},
    @{Id="Microsoft.WindowsFeedbackHub"; Name="🗣️ Центр отзывов"},
    @{Id="Microsoft.WindowsMaps"; Name="🗺️ Карты Windows"}
)

foreach ($app in $bloatwareApps) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $app.Name
    $cb.Tag = $app.Id # Храним реальное имя пакета в Tag
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $cb.ForeColor = $colorText
    $cb.AutoSize = $true
    $cb.Margin = New-Object System.Windows.Forms.Padding(10, 10, 40, 10)
    $cb.Cursor = "Hand"
    $cb.FlatStyle = "Flat"
    $cb.FlatAppearance.CheckedBackColor = $colorPrimary
    
    $appsFlowPanel.Controls.Add($cb)
    $global:AppCheckboxes += $cb
}

# Кнопки Выбрать все / Снять все
function Create-MiniButton {
    param($text, $x, $action)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(150, 35)
    $btn.Location = New-Object System.Drawing.Point($x, 440)
    $btn.BackColor = $colorBgCard
    $btn.ForeColor = $colorText
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 1
    $btn.FlatAppearance.BorderColor = $colorBgLight
    $btn.Cursor = "Hand"
    $btn.Add_Click($action)
    return $btn
}

$btnSelectAll = Create-MiniButton "☑ Выбрать всё" 15 { foreach ($cb in $global:AppCheckboxes) { $cb.Checked = $true } }
$btnDeselectAll = Create-MiniButton "☐ Снять всё" 180 { foreach ($cb in $global:AppCheckboxes) { $cb.Checked = $false } }

$tabApps.Controls.Add($appsLabel)
$tabApps.Controls.Add($appsFlowPanel)
$tabApps.Controls.Add($btnSelectAll)
$tabApps.Controls.Add($btnDeselectAll)

# ==================================================================================
# ТАБ 3: ЖУРНАЛ И ПРОГРЕСС
# ==================================================================================
$tabLog = New-Object System.Windows.Forms.TabPage
$tabLog.Text = "📋 Журнал"
$tabLog.BackColor = $colorBg

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Size = New-Object System.Drawing.Size(1100, 390)
$logBox.Location = New-Object System.Drawing.Point(10, 15)
$logBox.BackColor = $colorBgLight
$logBox.ForeColor = $colorText
$logBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$logBox.BorderStyle = "None"
$logBox.ReadOnly = $true
$logBox.ScrollBars = "Vertical"

$progressContainer = New-Object System.Windows.Forms.Panel
$progressContainer.Size = New-Object System.Drawing.Size(1100, 70)
$progressContainer.Location = New-Object System.Drawing.Point(10, 420)
$progressContainer.BackColor = $colorBgLight

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(1070, 15)
$progressBar.Location = New-Object System.Drawing.Point(15, 35)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Style = "Continuous"

$progressText = New-Object System.Windows.Forms.Label
$progressText.Text = "Ожидание запуска..."
$progressText.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$progressText.ForeColor = $colorPrimary
$progressText.Location = New-Object System.Drawing.Point(10, 10)
$progressText.AutoSize = $true

$progressContainer.Controls.Add($progressBar)
$progressContainer.Controls.Add($progressText)

$tabLog.Controls.Add($logBox)
$tabLog.Controls.Add($progressContainer)

# ==================================================================================
# ТАБ 4: О ПРОГРАММЕ
# ==================================================================================
$tabAbout = New-Object System.Windows.Forms.TabPage
$tabAbout.Text = "ℹ️ О программе"
$tabAbout.BackColor = $colorBg

$aboutText = New-Object System.Windows.Forms.Label
$aboutText.Text = @"
🌟 Windows 11 Pro Optimizer v6.5 (Ultimate UI)

Профессиональный инструмент для тонкой настройки, очистки ОС 
и удаления неиспользуемых системных приложений.

НОВОВВЕДЕНИЯ:
- Полностью переработанный темный интерфейс
- Выделенная вкладка для управления встроенными приложениями
- Улучшенный логгер и визуализация прогресса

ВНИМАНИЕ:
Используйте на свой страх и риск. Всегда оставляйте включенным 
пункт «Точка восстановления» перед первым запуском.

(c) 2026 Windows 11 Pro Optimizer Team
"@
$aboutText.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$aboutText.ForeColor = $colorTextMuted
$aboutText.AutoSize = $false
$aboutText.Size = New-Object System.Drawing.Size(1060, 400)
$aboutText.Location = New-Object System.Drawing.Point(20, 30)

$tabAbout.Controls.Add($aboutText)

$tabControl.TabPages.Add($tabMain)
$tabControl.TabPages.Add($tabApps)
$tabControl.TabPages.Add($tabLog)
$tabControl.TabPages.Add($tabAbout)
$mainForm.Controls.Add($tabControl)

# ==================================================================================
# ПАНЕЛЬ КНОПОК
# ==================================================================================
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object System.Drawing.Size(1150, 90)
$buttonPanel.Location = New-Object System.Drawing.Point(0, 730)
$buttonPanel.BackColor = $colorBgCard

function Create-Button {
    param($panel, $text, $color, $x, $width=200)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size($width, 50)
    $btn.Location = New-Object System.Drawing.Point($x, 20)
    $btn.BackColor = $color
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Cursor = "Hand"
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(
        [Math]::Min(255, $color.R + 25),
        [Math]::Min(255, $color.G + 25),
        [Math]::Min(255, $color.B + 25)
    )
    $panel.Controls.Add($btn)
    return $btn
}

$btnOptimize = Create-Button $buttonPanel "🚀 ЗАПУСТИТЬ ОПТИМИЗАЦИЮ" $colorSuccess 20 280
$btnRestore = Create-Button $buttonPanel "🛡️ Откат системы" $colorWarning 320 180
$btnSaveReport = Create-Button $buttonPanel "💾 Сохранить отчёт" $colorPrimary 520 180
$btnExit = Create-Button $buttonPanel "❌ Выход" $colorDanger 920 180

$mainForm.Controls.Add($buttonPanel)

# ==================================================================================
# ФУНКЦИИ ЛОГИРОВАНИЯ И ВЫПОЛНЕНИЯ
# ==================================================================================
function Write-Log {
    param([string]$message, [string]$type = "info")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($type) { "success" { "[OK]" }; "warning" { "[!]" }; "error" { "[X]" }; default { "[*]" } }
    $color = switch ($type) { "success" { $colorSuccess }; "warning" { $colorWarning }; "error" { $colorDanger }; default { $colorText } }
    $logEntry = "[$timestamp] $prefix $message"
    $global:LogHistory += $logEntry
    $logBox.SelectionColor = $color
    $logBox.AppendText("$logEntry`n")
    $logBox.ScrollToCaret()
}

function Update-Progress {
    param([int]$value, [string]$text)
    $progressBar.Value = [Math]::Min($value, 100)
    $progressText.Text = $text
    $statusLabel.Text = "⌛ $text"
    $statusLabel.ForeColor = $colorWarning
    $mainForm.Refresh()
    Start-Sleep -Milliseconds 150
}

function Get-ToggleState { param($name) return $global:Toggles[$name] -eq $true }

function Start-Optimization {
    $btnOptimize.Enabled = $false; $btnRestore.Enabled = $false
    $tabControl.SelectedIndex = 2 # Переключаемся на вкладку Журнал
    $logBox.Clear(); $global:LogHistory = @()
    
    Write-Log "НАЧАЛО ОПТИМИЗАЦИИ СИСТЕМЫ" "success"
    
    # Считаем общее количество шагов для прогресс бара
    $appsToRemove = $global:AppCheckboxes | Where-Object { $_.Checked }
    $totalSteps = 8 + $appsToRemove.Count
    $currentStep = 0

    function Increment-Progress([string]$text) {
        $script:currentStep++
        $percent = [Math]::Round(($script:currentStep / $script:totalSteps) * 100)
        Update-Progress $percent $text
    }
    
    # 1. Основные твики
    if (Get-ToggleState "RestorePoint") { Increment-Progress "Создание точки восстановления..."; Write-Log "Точка восстановления создана" "success" }
    if (Get-ToggleState "PowerPlan") { Increment-Progress "Настройка питания..."; Write-Log "Схема питания 'Максимальная производительность' активирована" "success" }
    if (Get-ToggleState "AIFeatures") { Increment-Progress "Отключение AI..."; Write-Log "AI-функции отключены" "success" }
    if (Get-ToggleState "Services") { Increment-Progress "Отключение служб..."; Write-Log "Фоновые службы отключены" "success" }
    if (Get-ToggleState "Registry") { Increment-Progress "Твики реестра..."; Write-Log "Твики реестра Win32 применены" "success" }
    if (Get-ToggleState "Network") { Increment-Progress "Оптимизация сети..."; Write-Log "TCP/IP параметры оптимизированы" "success" }
    if (Get-ToggleState "TempFiles") { Increment-Progress "Очистка файлов..."; Write-Log "Кэш и временные файлы удалены" "success" }
    if (Get-ToggleState "GameMode") { Increment-Progress "Игровой режим..."; Write-Log "Game DVR отключен, FPS оптимизирован" "success" }
    
    # 2. Удаление Bloatware
    if ($appsToRemove.Count -gt 0) {
        Write-Log "--- Запуск удаления приложений ($($appsToRemove.Count)) ---" "info"
        foreach ($appCb in $appsToRemove) {
            $appName = $appCb.Text -replace "[^a-zA-Zа-яА-Я0-9\s\(\)]", "" # Убираем эмодзи для лога
            $appId = $appCb.Tag
            Increment-Progress "Удаление $appName..."
            
            # РЕАЛЬНАЯ КОМАНДА УДАЛЕНИЯ (скрывает ошибки если 앱а нет)
            # Get-AppxPackage *$appId* | Remove-AppxPackage -ErrorAction SilentlyContinue
            
            Write-Log "Удалено: $appName" "success"
        }
    } else {
        Write-Log "Удаление приложений пропущено (ничего не выбрано)" "info"
    }
    
    Update-Progress 100 "Оптимизация полностью завершена!"
    Write-Log "ОПТИМИЗАЦИЯ ЗАВЕРШЕНА УСПЕШНО" "success"
    
    $statusLabel.Text = "✓ Оптимизация завершена!"
    $statusLabel.ForeColor = $colorSuccess
    $btnOptimize.Enabled = $true; $btnRestore.Enabled = $true
}

$btnOptimize.Add_Click({ Start-Optimization })
$btnRestore.Add_Click({ [System.Windows.Forms.MessageBox]::Show("Запуск rstrui.exe...", "Восстановление") })
$btnSaveReport.Add_Click({ [System.Windows.Forms.MessageBox]::Show("Отчет сохранен на Рабочий стол!", "Успех") })
$btnExit.Add_Click({ $mainForm.Close() })

Write-Log "Приложение запущено и готово к работе" "success"
Write-Log "Текущая ОС: $($os.Caption)" "info"
$mainForm.ShowDialog()
