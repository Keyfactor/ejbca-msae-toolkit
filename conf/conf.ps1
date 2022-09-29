# Global
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

## Logging
# 'INFO' or 'DEBUG'
$LogLevel = 'DEBUG'
# Number of past log sets to retain. Set to 0 to keep all logs.
$LogRetention = 1

## Download options. Set to true if you want the script to attempt to download items instead of ask for a file
# AIA Certificate
$DownloadCaCertsFromAIA = $true

## Testing
# Enable to include testing configurations
$TestingCode = $true
# Add start sleep between messages (milliseconds)
$AddSuspense = $true
$AddSuspenseTime = 500

## Remediation
$UseToolKit = $true