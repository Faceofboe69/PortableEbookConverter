<#
.SYNOPSIS
    Portable Ebook Converter - a no-install Windows GUI front-end for Calibre's
    ebook-convert tool. Batch-converts HTML, AZW, MOBI, PDF, FB2, LIT, TXT and
    many other formats to EPUB (and other output formats), including recursive
    scanning of nested sub-folders.

.DESCRIPTION
    No install required beyond Windows PowerShell (built into Windows 10/11) and
    a copy of Calibre's command line tools. The launcher (Run-Converter.cmd) will
    locate a portable Calibre automatically, or you can drop ebook-convert.exe in
    a 'calibre' sub-folder. Nothing is written to the system; it all runs from
    the folder you extracted it to.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Find-EbookConvert {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    if (-not $scriptDir) { $scriptDir = (Get-Location).Path }
    $candidates = @(
        (Join-Path $scriptDir 'calibre\ebook-convert.exe'),
        (Join-Path $scriptDir 'calibre-portable\Calibre\ebook-convert.exe'),
        (Join-Path $scriptDir 'ebook-convert.exe'),
        (Join-Path ${env:ProgramFiles} 'Calibre2\ebook-convert.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Calibre2\ebook-convert.exe')
    )
    foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
    $onPath = Get-Command 'ebook-convert.exe' -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }
    return $null
}

$InputFormats = @('epub','mobi','azw','azw3','azw4','html','htm','htmlz','pdf',
    'fb2','fbz','lit','lrf','odt','pdb','pml','rb','rtf','snb','tcr','txt','txtz',
    'cbz','cbr','docx')

$OutputFormats = @('epub','mobi','azw3','pdf','fb2','html','htmlz','lit','lrf',
    'pdb','pml','rb','rtf','snb','tcr','txt','txtz','docx','oeb')

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Portable Ebook Converter'
$form.Size = New-Object System.Drawing.Size(720, 560)
$form.StartPosition = 'CenterScreen'
$form.MinimumSize = New-Object System.Drawing.Size(640, 480)

$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = 'Source (file or folder):'
$lblSource.Location = New-Object System.Drawing.Point(12, 15)
$lblSource.AutoSize = $true
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(15, 35)
$txtSource.Size = New-Object System.Drawing.Size(500, 24)
$txtSource.Anchor = 'Top,Left,Right'
$form.Controls.Add($txtSource)

$btnPickFolder = New-Object System.Windows.Forms.Button
$btnPickFolder.Text = 'Folder...'
$btnPickFolder.Location = New-Object System.Drawing.Point(525, 34)
$btnPickFolder.Size = New-Object System.Drawing.Size(80, 26)
$btnPickFolder.Anchor = 'Top,Right'
$form.Controls.Add($btnPickFolder)

$btnPickFile = New-Object System.Windows.Forms.Button
$btnPickFile.Text = 'File...'
$btnPickFile.Location = New-Object System.Drawing.Point(613, 34)
$btnPickFile.Size = New-Object System.Drawing.Size(80, 26)
$btnPickFile.Anchor = 'Top,Right'
$form.Controls.Add($btnPickFile)

$chkRecurse = New-Object System.Windows.Forms.CheckBox
$chkRecurse.Text = 'Include files in nested sub-folders (recursive)'
$chkRecurse.Location = New-Object System.Drawing.Point(15, 68)
$chkRecurse.AutoSize = $true
$chkRecurse.Checked = $true
$form.Controls.Add($chkRecurse)

$lblOut = New-Object System.Windows.Forms.Label
$lblOut.Text = 'Convert to:'
$lblOut.Location = New-Object System.Drawing.Point(15, 100)
$lblOut.AutoSize = $true
$form.Controls.Add($lblOut)

$cmbOut = New-Object System.Windows.Forms.ComboBox
$cmbOut.DropDownStyle = 'DropDownList'
$cmbOut.Location = New-Object System.Drawing.Point(90, 96)
$cmbOut.Size = New-Object System.Drawing.Size(120, 24)
foreach ($f in $OutputFormats) { [void]$cmbOut.Items.Add($f) }
$cmbOut.SelectedItem = 'epub'
$form.Controls.Add($cmbOut)

$chkSameFolder = New-Object System.Windows.Forms.CheckBox
$chkSameFolder.Text = 'Save output next to each source file'
$chkSameFolder.Location = New-Object System.Drawing.Point(230, 99)
$chkSameFolder.AutoSize = $true
$chkSameFolder.Checked = $true
$form.Controls.Add($chkSameFolder)

$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Text = 'Output folder:'
$lblDest.Location = New-Object System.Drawing.Point(15, 132)
$lblDest.AutoSize = $true
$form.Controls.Add($lblDest)

$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(100, 128)
$txtDest.Size = New-Object System.Drawing.Size(415, 24)
$txtDest.Anchor = 'Top,Left,Right'
$txtDest.Enabled = $false
$form.Controls.Add($txtDest)

$btnDest = New-Object System.Windows.Forms.Button
$btnDest.Text = 'Browse...'
$btnDest.Location = New-Object System.Drawing.Point(525, 127)
$btnDest.Size = New-Object System.Drawing.Size(80, 26)
$btnDest.Anchor = 'Top,Right'
$btnDest.Enabled = $false
$form.Controls.Add($btnDest)

$log = New-Object System.Windows.Forms.TextBox
$log.Multiline = $true
$log.ScrollBars = 'Vertical'
$log.ReadOnly = $true
$log.Location = New-Object System.Drawing.Point(15, 165)
$log.Size = New-Object System.Drawing.Size(678, 300)
$log.Anchor = 'Top,Bottom,Left,Right'
$log.Font = New-Object System.Drawing.Font('Consolas', 9)
$form.Controls.Add($log)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(15, 475)
$progress.Size = New-Object System.Drawing.Size(500, 22)
$progress.Anchor = 'Bottom,Left,Right'
$form.Controls.Add($progress)

$btnConvert = New-Object System.Windows.Forms.Button
$btnConvert.Text = 'Convert'
$btnConvert.Location = New-Object System.Drawing.Point(525, 472)
$btnConvert.Size = New-Object System.Drawing.Size(168, 28)
$btnConvert.Anchor = 'Bottom,Right'
$form.Controls.Add($btnConvert)

function Write-Log([string]$msg) {
    $log.AppendText(('{0}  {1}{2}' -f (Get-Date -Format 'HH:mm:ss'), $msg, [Environment]::NewLine))
    [System.Windows.Forms.Application]::DoEvents()
}

$chkSameFolder.Add_CheckedChanged({
    $useDest = -not $chkSameFolder.Checked
    $txtDest.Enabled = $useDest
    $btnDest.Enabled = $useDest
})

$btnPickFolder.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'Select the folder containing ebooks to convert'
    if ($dlg.ShowDialog() -eq 'OK') { $txtSource.Text = $dlg.SelectedPath }
})

$btnPickFile.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = 'Ebook & document files|*.epub;*.mobi;*.azw;*.azw3;*.html;*.htm;*.pdf;*.fb2;*.lit;*.lrf;*.txt;*.rtf;*.docx|All files|*.*'
    if ($dlg.ShowDialog() -eq 'OK') { $txtSource.Text = $dlg.FileName }
})

$btnDest.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'Select the output folder'
    if ($dlg.ShowDialog() -eq 'OK') { $txtDest.Text = $dlg.SelectedPath }
})

$btnConvert.Add_Click({
    $log.Clear()
    $exe = Find-EbookConvert
    if (-not $exe) {
        [System.Windows.Forms.MessageBox]::Show(
            "Could not find ebook-convert.exe.`r`n`r`nPlace a portable Calibre in a 'calibre' sub-folder next to this app, or install Calibre. See the README.",
            'Calibre not found', 'OK', 'Error') | Out-Null
        return
    }
    Write-Log "Using converter: $exe"
    $src = $txtSource.Text.Trim()
    if (-not $src -or -not (Test-Path $src)) {
        [System.Windows.Forms.MessageBox]::Show('Please choose a valid source file or folder.', 'No source', 'OK', 'Warning') | Out-Null
        return
    }
    $outFmt = $cmbOut.SelectedItem
    if (-not $outFmt) { $outFmt = 'epub' }
    $files = @()
    if (Test-Path $src -PathType Container) {
        $opt = @{ Path = $src; File = $true }
        if ($chkRecurse.Checked) { $opt['Recurse'] = $true }
        $all = Get-ChildItem @opt -ErrorAction SilentlyContinue
        $files = $all | Where-Object {
            $ext = $_.Extension.TrimStart('.').ToLower()
            ($InputFormats -contains $ext) -and ($ext -ne $outFmt)
        }
    } else {
        $files = @(Get-Item $src)
    }
    if (-not $files -or $files.Count -eq 0) {
        Write-Log 'No convertible files were found in the selected source.'
        return
    }
    Write-Log ("Found {0} file(s) to convert to .{1}" -f $files.Count, $outFmt)
    $progress.Value = 0
    $progress.Maximum = $files.Count
    $btnConvert.Enabled = $false
    $ok = 0; $fail = 0
    foreach ($f in $files) {
        if ($chkSameFolder.Checked) {
            $destDir = $f.DirectoryName
        } else {
            $destDir = $txtDest.Text.Trim()
            if (-not $destDir) { $destDir = $f.DirectoryName }
        }
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        $outFile = Join-Path $destDir ($f.BaseName + '.' + $outFmt)
        Write-Log ("Converting: {0}" -f $f.Name)
        try {
            $p = Start-Process -FilePath $exe -ArgumentList @("`"$($f.FullName)`"", "`"$outFile`"") -NoNewWindow -Wait -PassThru
            if ($p.ExitCode -eq 0) {
                $ok++
                Write-Log ("   -> OK: {0}" -f (Split-Path $outFile -Leaf))
            } else {
                $fail++
                Write-Log ("   -> FAILED (exit {0}): {1}" -f $p.ExitCode, $f.Name)
            }
        } catch {
            $fail++
            Write-Log ("   -> ERROR: {0}" -f $_.Exception.Message)
        }
        $progress.Value = [Math]::Min($progress.Value + 1, $progress.Maximum)
        [System.Windows.Forms.Application]::DoEvents()
    }
    Write-Log ("Done. {0} succeeded, {1} failed." -f $ok, $fail)
    $btnConvert.Enabled = $true
    [System.Windows.Forms.MessageBox]::Show(
        ("Conversion complete.`r`n`r`nSucceeded: {0}`r`nFailed: {1}" -f $ok, $fail),
        'Portable Ebook Converter', 'OK', 'Information') | Out-Null
})

[void]$form.ShowDialog()
