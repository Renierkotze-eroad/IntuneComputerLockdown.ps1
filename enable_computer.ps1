### This unfortunately does not restore previous admins which were removed. Do consider potentially restricting elevated privileges only
### to LAPS accounts though wherever possible

### Remove login message
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeCaption"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeText"
Write-Host "Login message removed successfully."

### Restore login
$secpolPath = "C:\secpol.cfg"
$SeInteractiveLogonRight = "seinteractivelogonright"

secedit /export /cfg $secpolPath

$secpol = Get-Content -Path $secpolPath
$SeIrlLine = $secpol | Where-Object {$_.ToLower().StartsWith($SeInteractiveLogonRight)}
$SeIlrIndex = $secpol.IndexOf($SeIrlLine)
$secpol[$SeIlrIndex] = "$SeInteractiveLogonRight = Guest,*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551"  # The default logon rights being restored

Set-Content -Path $secpolPath -Value $secpol
secedit /configure /db secedit.sdb /cfg $secpolPath /areas USER_RIGHTS

Remove-Item $secpolPath

Write-Host "Login restrictions removed successfully."
