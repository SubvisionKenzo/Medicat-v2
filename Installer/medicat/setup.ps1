Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================
# CHARGEMENT LANGUE
# ============================

$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SelectedLangFile = Join-Path $BasePath "selected_lang.txt"

if (-not (Test-Path $SelectedLangFile)) {
    [System.Windows.Forms.MessageBox]::Show("selected_lang.txt missing!")
    exit
}

$langCode = (Get-Content $SelectedLangFile -Raw).Trim()
Remove-Item $SelectedLangFile -Force

$langFile = Join-Path $BasePath "lang\$langCode.txt"
if (-not (Test-Path $langFile)) {
    $langFile = Join-Path $BasePath "lang\en.txt"
}

$LANGDATA = @{}
foreach ($line in Get-Content $langFile) {
    if ($line -match "^\s*$") { continue }
    if ($line -match "^\s*#") { continue }
    $parts = $line -split "=", 2
    if ($parts.Count -eq 2) {
        $LANGDATA[$parts[0]] = $parts[1]
    }
}

function T($key) {
    if ($LANGDATA.ContainsKey($key)) { return $LANGDATA[$key] }
    return $key
}

# ============================
# FENÊTRE PRINCIPALE
# ============================

$form = New-Object Windows.Forms.Form
$form.Text = "Medicat v2 Installer by SubvisionKenzo"
$form.Size = New-Object Drawing.Size(680, 450)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [Drawing.Color]::White

# Icône
$iconFile = Join-Path $BasePath "setup.ico"
if (Test-Path $iconFile) {
    $form.Icon = New-Object System.Drawing.Icon($iconFile)
}

# ============================
# PANNEAU GAUCHE (LOGO)
# ============================

$panelLeft = New-Object Windows.Forms.Panel
$panelLeft.Width = 200
$panelLeft.Height = $form.ClientSize.Height - 55
$panelLeft.Left = 0
$panelLeft.Top = 0
$panelLeft.BackColor = [Drawing.Color]::White
$form.Controls.Add($panelLeft)

$logoFile = Join-Path $BasePath "logo.png"
if (Test-Path $logoFile) {
    $picLogo = New-Object Windows.Forms.PictureBox
    $picLogo.Image = [System.Drawing.Image]::FromFile($logoFile)
    $picLogo.SizeMode = 'Zoom'
    $picLogo.Dock = 'Fill'
    $panelLeft.Controls.Add($picLogo)
}

# ============================
# PANNEAU CENTRAL ALIGNÉ
# ============================

$panelMain = New-Object Windows.Forms.Panel
$panelMain.Left   = 210
$panelMain.Top    = 10
$panelMain.Width  = $form.ClientSize.Width - 220
$panelMain.Height = $form.ClientSize.Height - 70
$panelMain.BackColor = [Drawing.Color]::White
$form.Controls.Add($panelMain)

# ============================
# STYLE MODERNE DES BOUTONS
# ============================

function Set-ModernButton {
    param($btn)

    if ($btn -isnot [System.Windows.Forms.Button]) {
        return
    }

    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    $btn.ForeColor = [Drawing.Color]::White
    $btn.Font = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
    $btn.Height = 32
    $btn.Width = 110

    $btn.Add_MouseEnter({
        $btn.BackColor = [Drawing.Color]::FromArgb(0, 140, 255)
    })
    $btn.Add_MouseLeave({
        $btn.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
    })
}

function New-RoundedInput {
    param(
        [string]$placeholder = "",
        [int]$width = 150
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Width = $width
    $panel.Height = 32
    $panel.BackColor = [Drawing.Color]::White
    $panel.BorderStyle = 'None'

    # Bord arrondi
    $panel.Region = New-Object System.Drawing.Region(
        (New-Object System.Drawing.Drawing2D.GraphicsPath)
    )
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.AddArc(0,0,32,32,180,90)
    $gp.AddArc($width-32,0,32,32,270,90)
    $gp.AddArc($width-32,0,32,32,0,90)
    $gp.AddArc(0,0,32,32,90,90)
    $panel.Region = New-Object System.Drawing.Region($gp)

    # TextBox interne
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.BorderStyle = 'None'
    $tb.Font = New-Object Drawing.Font("Segoe UI", 10)
    $tb.ForeColor = [Drawing.Color]::Black
    $tb.BackColor = [Drawing.Color]::White
    $tb.Location = "10,7"
    $tb.Width = $width - 20
    $tb.Text = $placeholder

    $panel.Controls.Add($tb)

    return $panel, $tb
}

# ============================
# BANDE BLEUE BAS
# ============================

$footer = New-Object Windows.Forms.Panel
$footer.Height = 55
$footer.Dock = 'Bottom'
$footer.BackColor = [Drawing.Color]::FromArgb(0, 120, 215)
$form.Controls.Add($footer)

# ============================
# PAGE 1 : PRÉSENTATION MODERNE
# ============================

$page1 = New-Object Windows.Forms.Panel
$page1.Parent = $panelMain
$page1.Dock   = 'Fill'
$page1.BackColor = [Drawing.Color]::White

$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text = T "WELCOME"
$lblTitle.Font = New-Object Drawing.Font("Segoe UI", 16, [Drawing.FontStyle]::Bold)
$lblTitle.AutoSize = $true
$lblTitle.Location = "18,15"
$page1.Controls.Add($lblTitle)

$lblDesc = New-Object Windows.Forms.Label
$lblDesc.Text = T "WELCOME_DESC"
$lblDesc.Font = New-Object Drawing.Font("Segoe UI", 11)
$lblDesc.AutoSize = $true
$lblDesc.Location = "20,70"
$page1.Controls.Add($lblDesc)

$lineDecor = New-Object Windows.Forms.Panel
$lineDecor.BackColor = [Drawing.Color]::FromArgb(0,120,215)
$lineDecor.Size = "450,3"
$lineDecor.Location = "20,110"
$page1.Controls.Add($lineDecor)

# ============================
# PAGE 2 : LICENCE
# ============================

$page2 = New-Object Windows.Forms.Panel
$page2.Parent = $panelMain
$page2.Dock   = 'Fill'
$page2.BackColor = [Drawing.Color]::White
$page2.Visible = $false

$lbl2 = New-Object Windows.Forms.Label
$lbl2.Text = T "LICENSE"
$lbl2.Font = New-Object Drawing.Font("Segoe UI", 16, [Drawing.FontStyle]::Bold)
$lbl2.AutoSize = $true
$lbl2.Location = "20,5"
$page2.Controls.Add($lbl2)

$txtLicense = New-Object Windows.Forms.TextBox
$txtLicense.Multiline = $true
$txtLicense.ScrollBars = 'Vertical'
$txtLicense.ReadOnly = $true
$txtLicense.Size = "450,260"
$txtLicense.Location = "20,40"

$LicenseFile = Join-Path $BasePath "licence.txt"
if (Test-Path $LicenseFile) {
    $txtLicense.Text = Get-Content $LicenseFile -Raw
} else {
    $txtLicense.Text = "licence.txt missing!"
}

$page2.Controls.Add($txtLicense)

$rbAccept = New-Object Windows.Forms.RadioButton
$rbAccept.Text = T "ACCEPT"
$rbAccept.Location = "20,310"
$page2.Controls.Add($rbAccept)

$rbDecline = New-Object Windows.Forms.RadioButton
$rbDecline.Text = T "DECLINE"
$rbDecline.Location = "125,310"
$page2.Controls.Add($rbDecline)

# ============================
# PAGE 3 : INSTALLATION
# ============================

$page3 = New-Object Windows.Forms.Panel
$page3.Parent = $panelMain
$page3.Dock   = 'Fill'
$page3.BackColor = [Drawing.Color]::White
$page3.Visible = $false

$lbl3 = New-Object Windows.Forms.Label
$lbl3.Text = T "INSTALL_CHOICE"
$lbl3.Font = New-Object Drawing.Font("Segoe UI", 16, [Drawing.FontStyle]::Bold)
$lbl3.AutoSize = $true
$lbl3.Location = "20,20"
$page3.Controls.Add($lbl3)

$lblUSB = New-Object Windows.Forms.Label
$lblUSB.Text = T "USB_LETTER"
$lblUSB.Location = "20,90"
$lblUSB.AutoSize = $true
$page3.Controls.Add($lblUSB)

$usbInput = New-RoundedInput -placeholder "select USB" -width 90
$usbPanel = $usbInput[0]
$txtUSB   = $usbInput[1]

$usbPanel.Location = "150,85"
$page3.Controls.Add($usbPanel)

$btnUSBSelect = New-Object Windows.Forms.Button
$btnUSBSelect.Text = "..."
$btnUSBSelect.Width = 22
$btnUSBSelect.Height = 22
$btnUSBSelect.Location = "250,85"
Set-ModernButton $btnUSBSelect
$page3.Controls.Add($btnUSBSelect)

$lblName = New-Object Windows.Forms.Label
$lblName.Text = T "USB_NAME"
$lblName.Location = "20,140"
$lblName.AutoSize = $true
$page3.Controls.Add($lblName)

$txtName = New-Object Windows.Forms.TextBox
$txtName.Size = "150,25"
$txtName.Location = "150,135"
$txtName.Text = "Medicat"
$page3.Controls.Add($txtName)

$txtUSB.Add_Click({
    [System.Windows.Forms.MessageBox]::Show((T "USB_WARNING"))
})

# ============================
# BOUTONS
# ============================

$btnNext1 = New-Object Windows.Forms.Button
$btnNext1.Text = T "NEXT"
$btnNext1.Location = "400,13"
Set-ModernButton $btnNext1
$footer.Controls.Add($btnNext1)

$btnBack2 = New-Object Windows.Forms.Button
$btnBack2.Text = T "BACK"
$btnBack2.Location = "280,13"
$btnBack2.Visible = $false
Set-ModernButton $btnBack2
$footer.Controls.Add($btnBack2)

$btnNext2 = New-Object Windows.Forms.Button
$btnNext2.Text = T "NEXT"
$btnNext2.Location = "400,13"
$btnNext2.Visible = $false
Set-ModernButton $btnNext2
$footer.Controls.Add($btnNext2)

$btnInstall = New-Object Windows.Forms.Button
$btnInstall.Text = T "INSTALL"
$btnInstall.Location = "400,13"
$btnInstall.Visible = $false
Set-ModernButton $btnInstall
$footer.Controls.Add($btnInstall)

$btnCancel = New-Object Windows.Forms.Button
$btnCancel.Text = T "CANCEL"
$btnCancel.Location = "520,13"
Set-ModernButton $btnCancel
$footer.Controls.Add($btnCancel)
$btnCancel.Add_Click({ $form.Close() })

# ============================
# LOGIQUE DES PAGES
# ============================

$btnNext1.Add_Click({
    $page1.Visible = $false
    $page2.Visible = $true
    $btnNext1.Visible = $false
    $btnBack2.Visible = $true
    $btnNext2.Visible = $true
})

$btnBack2.Add_Click({
    $page2.Visible = $false
    $page1.Visible = $true
    $btnBack2.Visible = $false
    $btnNext2.Visible = $false
    $btnNext1.Visible = $true
})

$btnNext2.Add_Click({
    if (-not $rbAccept.Checked) {
        [System.Windows.Forms.MessageBox]::Show((T "NEED_ACCEPT"))
        return
    }

    $page2.Visible = $false
    $page3.Visible = $true

    $btnBack2.Visible = $false
    $btnNext2.Visible = $false
    $btnInstall.Visible = $true
})

$btnUSBSelect.Add_Click({

    $volumes = Get-Volume | Where-Object DriveType -eq 'Removable'

    if ($volumes.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Not USB key found.")
        return
    }

    $formSelect = New-Object Windows.Forms.Form
    $formSelect.Text = T "USB_SELECT"
    $formSelect.Size = "300,200"
    $formSelect.StartPosition = "CenterParent"

    $list = New-Object Windows.Forms.ListBox
    $list.Dock = 'Fill'

    foreach ($v in $volumes) {
        $list.Items.Add("$($v.DriveLetter):\  -  $($v.FileSystemLabel)")
    }

    $formSelect.Controls.Add($list)

    $list.Add_DoubleClick({
        if ($list.SelectedItem) {
            $txtUSB.Text = $list.SelectedItem.Substring(0,1)
            $formSelect.Close()
        }
    })

    $formSelect.ShowDialog()
})

$btnInstall.Add_Click({

    # Récupère la lettre telle quelle
    $letter = $txtUSB.Text.ToString().Trim()

    # Si vide → stop
    if ([string]::IsNullOrWhiteSpace($letter)) {
        [System.Windows.Forms.MessageBox]::Show("Aucune lettre USB n'a été saisie.")
        return
    }

    # Garde uniquement le premier caractère
    $letter = $letter.Substring(0,1).ToUpper()

    # Vérifie que download.bat existe
    $bat = Join-Path $BasePath "download.bat"
    if (-not (Test-Path $bat)) {
        [System.Windows.Forms.MessageBox]::Show("download.bat est introuvable !")
        return
    }

    # Envoie uniquement la lettre au batch
    Start-Process $bat -ArgumentList $letter, $txtName.Text

    $form.Close()
})

$form.ShowDialog()