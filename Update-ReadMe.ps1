Import-Module UncommonSense.Traffic -Force

Get-Command -Module UncommonSense.Traffic |
    Sort-Object -Property Noun, Verb |
    Get-HelpAsMarkDown -Title UncommonSense.Traffic -Description 'PowerShell module for retrieving Dutch road works information' |
    Out-File ./README.md -Encoding utf8
    