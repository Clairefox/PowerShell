<#
    .SYNOPSIS
    This script collects Azure Automation event logs from a hybrid worker VM.

    .DESCRIPTION
    This script creates a gui. There"s a form at the top to enter your server credentials
    and server IP/DNS, then click the button to retrieve the latest logs. This can help
    if you"re too lazy to log into the server, open event management, search through all
    of the logs for these specific ones.. if you like the conveniece of having the logs
    pulled for you!

    .NOTES
    Requires an Azure Account, Azure VMs created/setup and remotely accessible.

    Note, it can take a long time to parse through event management logs, even this script
    seems to take some time - so only the latest 20 azure automation events are returned.

    Script Inspiration/Help:
        https://adamtheautomator.com/build-powershell-gui/
        https://powershell.org/forums/topic/powershell-gui-tabcontrol/
#>


#region Application Functions
function Get-SMALogs () {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0,Mandatory = $true)]
            [string]$server,
            
        [Parameter(Position = 1,Mandatory = $true)]
            [string]$username,

        [Parameter(Position = 2,Mandatory = $true)]
            [SecureString]$securePassword
    ) #end param

    $credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList @($username,$securePassword)
    $outputbox.Text = "One moment please.. Retrieving Logs.."

    try {
        $session = New-PSSession -ComputerName "$server" -Credential $credentials -ErrorVariable "sessionError"
    } catch {
        $outputbox.Text = "Error connecting. Please verify your credentials and/or if $server is available and try again. `r`n "
        $outputbox.AppendText($sessionError)
    } #end try/catch

    if ($session) {
        $sessionLogs = Invoke-Command -Session $session -ScriptBlock { Get-WinEvent -LogName "Microsoft-SMA/Operational" -MaxEvents 20 }
        $outputbox.Text = $sessionLogs | Select-Object @{Name="ID:";Expression={[string]$_.Id}}, `
                                                       @{Name="Time:";Expression={[string]$_.TimeCreated}}, `
                                                       @{Name="Task:";Expression={[string]$_.TaskDisplayName}}, `
                                                       @{Name="Message:";Expression={[string]$_.Message}} `
                                       | Format-Table -AutoSize `
                                       | Out-String -Width 1000
    } else {
        $outputbox.Text = "Error retrieving logs. Please verify on server and see the following error: `r`n"
        $outputbox.AppendText($sessionError)
    }

    Get-PSSession | Remove-PSSession
    return $outputbox
} #end Get-SMALogs
#endregion

#region Generated Form Function
function Show-Form {
	#region Import the Assemblies
    [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    [void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    [void][reflection.assembly]::Load("System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	#endregion

	#region Generated Form Objects
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $form = New-Object "System.Windows.Forms.Form"
    $tabcontrol = New-Object "System.Windows.Forms.TabControl"
    $tabpage = New-Object "System.Windows.Forms.TabPage"
    $button = New-Object "System.Windows.Forms.Button"
    $labelServer = New-Object "System.Windows.Forms.Label"
    $textboxServer = New-Object "System.Windows.Forms.Textbox"
    $labelUsername = New-Object "System.Windows.Forms.Label"
    $textboxUsername = New-Object "System.Windows.Forms.Textbox"
    $labelPassword = New-Object "System.Windows.Forms.Label"
    $textboxPassword = New-Object "System.Windows.Forms.Textbox"
    $InitialFormWindowState = New-Object "System.Windows.Forms.FormWindowState"
	#endregion

	#region User Generated Script
    $form_Load = {}

    $button_RunOnClick = {
        if (!$textboxUsername.Text) {
            $outputbox.Text = "Username required. Please provide your Azure Account credentials."
        } else {
            if (!$textboxPassword.Text) {
                $outputbox.Text = "Password required. Please provide your Azure Account credentials."
            } else {
                if (!$textboxServer.Text) {
                    $outputbox.Text = "Server address required. Please provide an IP address or DNS to the server."   
                } else {
                    $server = $textboxServer.Text
                    $username = $textboxUsername.Text
                    $password = $textboxPassword.Text
                    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
                    Get-SMALogs $server $username $securePassword
                }
            }
        }      
    }
	#endregion

    #region Generated Events
	$Form_StateCorrection_Load= {
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed= {
		#Remove all event handlers from the controls
		try {
			$form.remove_Load($form_Load)
			$form.remove_Load($Form_StateCorrection_Load)
			$form.remove_FormClosed($Form_Cleanup_FormClosed)
		} catch { 
            Out-Null 
        }
	}
	#endregion

	#region Generated Form Code
	$form.SuspendLayout()
	$tabcontrol.SuspendLayout()

        #region form
        $form.Controls.Add($tabcontrol)
        $form.AutoScaleDimensions = "6, 13"
        $form.AutoScaleMode = "Font"
        $form.ClientSize = "1000, 705"
        $form.Name = "form"
        $form.Text = "Azure HybridWorkers - Runbook Event Logs"
        $form.add_Load($form_Load)
        #endregion

        #region Server/Credentials fields
        $labelServer.Text = "Server:"
        $labelServer.Location = New-Object System.Drawing.Point(12,5)
        $labelServer.Size = New-Object System.Drawing.Size(60,30)
        $form.Controls.Add($labelServer)

        $textboxServer.Name = "textboxServer"
        $textboxServer.Location = New-Object System.Drawing.Point(72,5)
        $textboxServer.Size = New-Object System.Drawing.Size(90,20)
        $form.Controls.Add($textboxServer)

        $labelUsername.Text = "Username:"
        $labelUsername.Location = New-Object System.Drawing.Point(195,5)
        $labelUsername.Size = New-Object System.Drawing.Size(60,30)
        $form.Controls.Add($labelUsername)

        $textboxUsername.Name = "textboxUsername"
        $textboxUsername.Location = New-Object System.Drawing.Point(260,5)
        $textboxUsername.Size = New-Object System.Drawing.Size(90,20)
        $form.Controls.Add($textboxUsername)

        $labelPassword.Text = "Password:"
        $labelPassword.Location = New-Object System.Drawing.Point(378,5)
        $labelPassword.Size = New-Object System.Drawing.Size(60,30)
        $form.Controls.Add($labelPassword)

        $textboxPassword.Name = "textboxPassword"
        $textboxPassword.Location = New-Object System.Drawing.Point(448,5)
        $textboxPassword.Size = New-Object System.Drawing.Size(90,20)
        $textboxPassword.PasswordChar = "*"
        $form.Controls.Add($textboxPassword)
        #endregion

        #region tabcontrol
        $tabcontrol.Controls.Add($tabpage)
        $tabcontrol.Alignment = "Left"
        $tabcontrol.Location = "12, 25"
        $tabcontrol.Multiline = $True
        $tabcontrol.Name = "tabcontrol"
        $tabcontrol.SelectedIndex = 0
        $tabcontrol.Size = "975, 665"
        $tabcontrol.TabIndex = 0
        #endregion

        #region tabpage
        $tabpage.Location = "5, 5"
        $tabpage.Name = "tabpage"
        $tabpage.Padding = "3, 2, 3, 3"
        $tabpage.Size = "583, 500"
        $tabpage.TabIndex = 0
        $tabpage.Text = "Azure Automation Logs"
        $tabpage.UseVisualStyleBackColor = $True

        $button.Name = "button"
        $button.Text = "Refresh Logs"
        $button.Location = New-Object System.Drawing.Point(12,5)
        $button.Size = New-Object System.Drawing.Size(100,20)
        $button.UseVisualStyleBackColor = $True
        $button.add_Click($button_RunOnClick)
        $tabpage.Controls.Add($button)

        $outputbox = New-Object System.Windows.Forms.TextBox
        $outputbox.Location = New-Object System.Drawing.Size(10,30)
        $outputbox.Size = New-Object System.Drawing.Size(930,620)
        $outputbox.Multiline = $True
        $outputbox.ScrollBars = "Both"
        $outputbox.Text = "Please provide your Azure Account Username and Password."
        $outputbox.Font = "Lucida Console"
        $tabpage.Controls.Add($outputbox)
        #endregion
	#endregion

	#Save the initial state of the form
    $InitialFormWindowState = $form.WindowState
    
	#Init the OnLoad event to correct the initial state of the form
    $form.add_Load($Form_StateCorrection_Load)
    
	#Clean up the control events
    $form.add_FormClosed($Form_Cleanup_FormClosed)
    
	#Show the Form
	return $form.ShowDialog()

} #end Show-Form

#Call the form
Show-Form | Out-Null