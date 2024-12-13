Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Quotes Entry Form'
$form.Size = New-Object System.Drawing.Size(340,250)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Enabled = $false
$okButton.Location = New-Object System.Drawing.Point(85,170)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(170,170)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(320,20)
$label.Text = '1: End User Company Name'
$form.Controls.Add($label)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10,40)
$textBox1.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($textBox1)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,70)
$label.Size = New-Object System.Drawing.Size(320,20)
$label.Text = '2: Plant Location'
$form.Controls.Add($label)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10,90)
$textBox2.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($textBox2)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,120)
$label.Size = New-Object System.Drawing.Size(320,20)
$label.Text = '3: Q24XXXX Project Name Description, Product, Capacity'
$form.Controls.Add($label)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10,140)
$textBox3.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($textBox3)

$form.Topmost = $true

$form.Add_Shown({$textBox1.Select()})

function Check-EnableOkButton {
    if ($textBox1.Text -ne "" -and $textBox2.Text -ne "" -and $textBox3.Text -ne "") {
        $okButton.Enabled = $true
    } else {
        $okButton.Enabled = $false
    }
}

# Add TextChanged event handlers for all three textboxes
$textBox1.Add_TextChanged({ Check-EnableOkButton })
$textBox2.Add_TextChanged({ Check-EnableOkButton })
$textBox3.Add_TextChanged({ Check-EnableOkButton })
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $endUserCompanyFLDR = $textBox1.Text
    $plantLocationFLDR = $textBox2.Text
    $projectNameFLDR = $textBox3.text
}

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    exit
}

#create level 1,2 folder
$parentDir = "" #Parent folder path
cd $parentDir
mkdir $endUserCompanyFLDR -ErrorAction SilentlyContinue | Out-Null
cd "$parentDir\$endUserCompanyFLDR"
mkdir $plantLocationFLDR -ErrorAction SilentlyContinue | Out-Null

#create level 3 folder
cd "$parentDir\$endUserCompanyFLDR\$plantLocationFLDR"
mkdir $projectNameFLDR -ErrorAction SilentlyContinue | Out-Null

#ACL
$RO = New-Object System.Security.AccessControl.FileSystemAccessRule('', "Read", "Allow") #Security group, Permission, Allow/Deny

$parentFolderACL = Get-Acl "$parentDir\$endUserCompanyFLDR"
$parentFolderACL.SetAccessRule($RO)
$parentFolderACL | Set-Acl "$parentDir\$endUserCompanyFLDR" -ErrorAction SilentlyContinue | Out-Null
$parentFolderACL | Set-Acl "$parentDir\$endUserCompanyFLDR\$plantLocationFLDR" -ErrorAction SilentlyContinue | Out-Null
$parentFolderACL | Set-Acl "$parentDir\$endUserCompanyFLDR\$plantLocationFLDR\$projectNameFLDR"  -ErrorAction SilentlyContinue | Out-Null


#    ╔═════════════╦═════════════╦═══════════════════════════════╦════════════════════════╦══════════════════╦═══════════════════════╦═════════════╦═════════════╗
#    ║             ║ folder only ║ folder, sub-folders and files ║ folder and sub-folders ║ folder and files ║ sub-folders and files ║ sub-folders ║    files    ║
#    ╠═════════════╬═════════════╬═══════════════════════════════╬════════════════════════╬══════════════════╬═══════════════════════╬═════════════╬═════════════╣
#    ║ Propagation ║ none        ║ none                          ║ none                   ║ none             ║ InheritOnly           ║ InheritOnly ║ InheritOnly ║
#    ║ Inheritance ║ none        ║ Container|Object              ║ Container              ║ Object           ║ Container|Object      ║ Container   ║ Object      ║
#    ╚═════════════╩═════════════╩═══════════════════════════════╩════════════════════════╩══════════════════╩═══════════════════════╩═════════════╩═════════════╝

$subfolderInheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$RE = New-Object System.Security.AccessControl.FileSystemAccessRule('', "ReadAndExecute", $subfolderInheritanceFlags, "None", "Allow") #Security group, Permission, Inheritance, Propagation, Allow/Deny
                           
#create level 4 & 5 folders
cd $projectNameFLDR
mkdir "1. Scope" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\1. Scope and Correspondence" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\1. Scope and Correspondence\Archive"  -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\2. RFP Documents" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\2. RFP Documents\Archive" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\3. Mass Balance and Calculations" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\1. Scope\3. Mass Balance and Calculations\Archive" -ErrorAction SilentlyContinue | Out-Null

$parentFolderACL = Get-Acl "1. Scope"
$parentFolderACL.SetAccessRule($RE)
$parentFolderACL | Set-Acl ".\1. Scope" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\2. Proposals" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\2. Proposals\Archive" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\3. BOM and Budget" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\3. BOM and Budget\Archive" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\4. Buyouts and Supplier Quotes" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\4. Buyouts and Supplier Quotes\Archive" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\5. Equipment Drawings and Layouts" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\5. Equipment Drawings and Layouts\Archive" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\6. Submitted to Cust" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\6. Submitted to Cust\Archive" -ErrorAction SilentlyContinue | Out-Null

mkdir ".\7. PO and Order Confirmation" -ErrorAction SilentlyContinue | Out-Null
mkdir ".\7. PO and Order Confirmation\Archive" -ErrorAction SilentlyContinue | Out-Null