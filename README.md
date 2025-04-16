README

Windows Lockdown Script for Intune Deployment

Description
This PowerShell script is designed to lock down a Windows system by performing the following actions:
1.	Customize the login message to display a warning to users attempting to log in.
2.	Restrict login access to specific accounts, preventing unauthorized users from logging into the machine.
3.	Remove non-approved administrator accounts from the local Administrators group for added security.
4.	Log off all active users, ensuring no ongoing sessions persist after the script's execution.
Designed for Microsoft Intune deployment, this script can be pushed centrally to manage Windows devices in your organization as part of security incident response, administrative enforcement, or device lockdown strategy.
Features
•	Login Message Customization: Sets a custom title and message displayed on the login screen.
•	User Access Restriction: Limits login access to pre-approved accounts only.
•	Cleanup Administrators Group: Removes residual administrator accounts to enforce security policies.
•	Immediate User Logoff: Ends all active user sessions on the system.
________________________________________
Usage with Intune
Pre-requisites
1.	The script needs to be deployed using Intune PowerShell script feature.
2.	Ensure Intune policies are configured properly to grant script execution permissions on targeted devices.
3.	Administrative privileges on the target device are required for the script to apply settings successfully.
4.	Familiarity with the $LAPS account and the accounts specified in $allowedUsers is necessary for proper configuration.
Configuration
Before uploading the script to Intune, review and configure the following variables within the script:
Login Message Customization
•	Update the below variables to set the desired login message:

$title = "This device has been disabled"
$message = "We've locked you out. Please contact your administrator."


Allowed Accounts
•	Add the accounts (domain or local) you want to retain login permissions:

$allowedUsers = @(
    "AzureAD\account@domain.com",     # Replace with your Azure AD account
    "DOMAIN\username",                # Replace with your domain account
    $LAPS                             # Replace with your LAPS administrator account reference
) -join ","

________________________________________
Script Deployment in Intune
Follow these steps to deploy the script in Intune:
Step 1: Prepare the Script
•	Save the script as LockdownScript.ps1.
Step 2: Upload to Intune
1.	Log in to the Microsoft Intune admin center .
2.	Navigate to Devices > Scripts.
3.	Click Add and select Windows 10 and later.
4.	Provide a name for the script, e.g., "Windows Lockdown Script".
5.	Upload the LockdownScript.ps1 file.
6.	Configure the following options:
•	Run script as signed-in user: No (script must run with system privileges).
•	Enforce script signature check: No.
•	Run script in 64-bit PowerShell Host: Yes.
Step 3: Assign Scope
1.	Assign the script to the desired groups or devices.
2.	Configure scheduling and compliance policies as needed.
________________________________________
What the Script Does
1.	Login Message Customization:
•	Updates the registry keys LegalNoticeCaption and LegalNoticeText under HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System.
•	Displays a custom warning message on the login screen.
2.	User Login Restriction:
•	Exports the local security policy using secedit.
•	Modifies the SeInteractiveLogonRight field to restrict logon rights to only the accounts listed in $allowedUsers.
•	Updates the system's policy using secedit.
3.	Administrators Group Cleanup:
•	Lists all accounts in the local Administrators group.
•	Removes all accounts except those explicitly allowed (e.g., $LAPS).
4.	Log Off Active Users:
•	Retrieves active user sessions via WMI and forces logoff using Win32_Shutdown.
________________________________________
Important Notes
1.	Testing:
•	DO NOT directly deploy to all devices without testing. Always test the script on a small group or sandbox environment before wider rollout.
•	Validate that legitimate users (e.g., IT administrators) can still access the device after script execution.
2.	Recovery Options:
•	Ensure you have recovery methods available for locked-out devices, such as alternate accounts, recovery tools, or physical access for offline remediation.
3.	Impact on Users:
•	This script will log off all active user sessions upon execution, potentially disrupting ongoing work.
•	Users trying to log in and not part of $allowedUsers will be denied access.
________________________________________
Custom Configuration for Intune
To customize the script for Intune deployment, you can modify or add relevant logging/reporting mechanisms (e.g., log output to a text file in a shared directory or report execution status to an endpoint in your tenant).
________________________________________
Error Handling
If Intune reports failure after running the script:
1.	Verify the affected devices have sufficient permissions to run scripts.
2.	Check the $allowedUsers list for proper formatting and ensure correct account names are provided.
3.	Validate that the target system meets the requirements for secedit policy changes.
