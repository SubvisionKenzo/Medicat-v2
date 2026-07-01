param(
    [string]$WindowTitle = "MediCat v2 SAFE Installer"
)

Add-Type -AssemblyName PresentationFramework

# --- XAML FIXÉ (ajout de xmlns:x) ---
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$WindowTitle"
        Height="180" Width="360"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#f3f3f3"
        FontFamily="Segoe UI">

    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Text="Choose your language :"
                   FontSize="14"
                   Margin="0,0,0,10"/>

        <ComboBox x:Name="LangBox"
                  Grid.Row="1"
                  Height="32"
                  FontSize="14"
                  Background="White"
                  BorderBrush="#cccccc"/>

        <Button x:Name="OkButton"
                Grid.Row="2"
                Content="Continuer"
                Width="120"
                Height="32"
                Margin="0,15,0,0"
                HorizontalAlignment="Center"
                Background="#0078D4"
                Foreground="White"
                FontWeight="Bold"
                BorderThickness="0"/>
    </Grid>
</Window>
"@

# Charger l'interface WPF
$reader = New-Object System.Xml.XmlNodeReader ([xml]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Récupérer les contrôles
$LangBox = $Window.FindName("LangBox")
$OkButton = $Window.FindName("OkButton")

# Charger les langues
$langFolder = Join-Path $PSScriptRoot "lang"
$langFiles = Get-ChildItem $langFolder -Filter *.txt

foreach ($file in $langFiles) {
    $LangBox.Items.Add([System.IO.Path]::GetFileNameWithoutExtension($file.Name))
}

$LangBox.SelectedIndex = 0

# Bouton OK
$OkButton.Add_Click({
    $selected = $LangBox.SelectedItem
    Set-Content -Path "$PSScriptRoot\selected_lang.txt" -Value $selected
    $Window.Close()
})

# Afficher la fenêtre
$Window.ShowDialog() | Out-Null