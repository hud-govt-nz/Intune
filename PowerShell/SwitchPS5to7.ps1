#Load this into ise and run it. It will add two new menu items to the Add-ons menu in the ISE. You can then switch between PowerShell 5 and 7 by pressing ALT+F5 and ALT+F6 respectively. This is useful if you want to test your scripts in both versions of PowerShell.

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to PowerShell 7", { 
        function New-OutOfProcRunspace {
            param($ProcessId)

            $ci = New-Object -TypeName System.Management.Automation.Runspaces.NamedPipeConnectionInfo -ArgumentList @($ProcessId)
            $tt = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()

            $Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($ci, $Host, $tt)

            $Runspace.Open()
            $Runspace
        }

        $PowerShell = Start-Process PWSH -ArgumentList @("-NoExit") -PassThru -WindowStyle Hidden
        $Runspace = New-OutOfProcRunspace -ProcessId $PowerShell.Id
        $Host.PushRunspace($Runspace)
}, "ALT+F5") | Out-Null

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to Windows PowerShell", { 
    $Host.PopRunspace()

    $Child = Get-CimInstance -ClassName win32_process | where {$_.ParentProcessId -eq $Pid}
    $Child | ForEach-Object { Stop-Process -Id $_.ProcessId }

}, "ALT+F6") | Out-Null