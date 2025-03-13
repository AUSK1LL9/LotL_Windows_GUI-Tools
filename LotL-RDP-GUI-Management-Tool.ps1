Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#region Form Creation
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Desktop Manager"
$form.Width = 400
$form.Height = 300

#region Labels and TextBoxes
$lblServer = New-Object System.Windows.Forms.Label
$lblServer.Text = "Server:"
$lblServer.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($lblServer)

$txtServer = New-Object System.Windows.Forms.TextBox
$txtServer.Location = New-Object System.Drawing.Point(80, 10)
$txtServer.Width = 200
$form.Controls.Add($txtServer)

$lblUsername = New-Object System.Windows.Forms.Label
$lblUsername.Text = "Username:"
$lblUsername.Location = New-Object System.Drawing.Point(10, 40)
$form.Controls.Add($lblUsername)

$txtUsername = New-Object System.Windows.Forms.TextBox
$txtUsername.Location = New-Object System.Drawing.Point(80, 40)
$txtUsername.Width = 200
$form.Controls.Add($txtUsername)

#endregion

#region Buttons
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = "Add"
$btnAdd.Location = New-Object System.Drawing.Point(10, 80)
$form.Controls.Add($btnAdd)

$btnRemove = New-Object System.Windows.Forms.Button
$btnRemove.Text = "Remove"
$btnRemove.Location = New-Object System.Drawing.Point(80, 80)
$form.Controls.Add($btnRemove)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Text = "Connect"
$btnConnect.Location = New-Object System.Drawing.Point(150, 80)
$form.Controls.Add($btnConnect)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(220, 80)
$form.Controls.Add($btnExit)
#endregion

#region ListBox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 120)
$listBox.Width = 350
$listBox.Height = 120
$form.Controls.Add($listBox)
#endregion

#endregion

#region CSV File Handling
$csvFile = "S:\RDPConnections.csv"

# Function to load connections from CSV
function Load-Connections {
    if (Test-Path $csvFile) {
        Import-Csv $csvFile | ForEach-Object { $listBox.Items.Add("$($_.Server),$($_.Username)") }
    }
}

# Function to save connections to CSV
function Save-Connections {
    $connections = @()
    foreach ($item in $listBox.Items) {
        $server, $username = $item -split ","
        $connections += [PSCustomObject]@{ Server = $server; Username = $username }
    }
    $connections | Export-Csv $csvFile -NoTypeInformation
}

# Load connections on form load
Load-Connections
#endregion

#region Button Events
$btnAdd.Add_Click({
    $listBox.Items.Add("$($txtServer.Text),$($txtUsername.Text)")
    $txtServer.Clear()
    $txtUsername.Clear()
    Save-Connections
})

$btnRemove.Add_Click({
    if ($listBox.SelectedItem) {
        $listBox.Items.Remove($listBox.SelectedItem)
        Save-Connections
    }
})

$btnConnect.Add_Click({
    if ($listBox.SelectedItem) {
        $server, $username = $listBox.SelectedItem -split ","
        # Construct the mstsc command
        $mstsc = "mstsc /v:$server /u:$username" # Add /p if you want to prompt for password
        Invoke-Expression $mstsc
    }
})

$btnExit.Add_Click({
    $form.Close()
})
#endregion

$form.ShowDialog()
