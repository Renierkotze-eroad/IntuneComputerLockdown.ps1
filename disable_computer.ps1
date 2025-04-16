### Reused constants
$LAPS = "LAPSACCOUNTNAME"

### Set login message
$title = "This device has been disabled"
$message = "We've locked you out. Congrats."

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeCaption" -Value $title
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeText" -Value $message
Write-Host "Login message updated successfully."


### Restrict login
$allowedUsers = @(  # Add any accounts here that should still be able to log in, comma-separated
    "AzureAD\cloud-account@yourdomain.com",
    "YOURDOMAIN\sharkboy",
    $LAPS
    ) -join ","

$secpolPath = "C:\secpol.cfg"
$SeInteractiveLogonRight = "seinteractivelogonright"

secedit /export /cfg $secpolPath

$secpol = Get-Content -Path $secpolPath
$SeIrlLine = $secpol | Where-Object {$_.ToLower().StartsWith($SeInteractiveLogonRight)}
$SeIlrIndex = $secpol.IndexOf($SeIrlLine)
$secpol[$SeIlrIndex] = "$SeInteractiveLogonRight = $allowedUsers"

Set-Content -Path $secpolPath -Value $secpol
secedit /configure /db secedit.sdb /cfg $secpolPath /areas USER_RIGHTS

Remove-Item $secpolPath

Write-Host "Login restrictions updated successfully."


### Clean up any Administrators group residuals
$Nlg = net localgroup administrators
$Administrators = $Nlg[6..($Nlg.count - 3)]  # Index of 6 is first administrator, index of -3 is the last

foreach ($Admin in $Administrators) {
    if ($Admin -ne $LAPS) {
        net localgroup administrators /delete $Admin
    }
}
Write-Host "All improper admin accounts cleared"



### Log off all users
(Get-WmiObject -Class win32_operatingsystem -Filter "Primary=true").Win32Shutdown(4)
Write-Host "All users have been logged off."
