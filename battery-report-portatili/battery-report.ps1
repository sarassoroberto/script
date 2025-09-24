$reportPath = "$env:USERPROFILE\Documents\battery-report.html"
powercfg /batteryreport /output $reportPath
Start-Process $reportPath
pause