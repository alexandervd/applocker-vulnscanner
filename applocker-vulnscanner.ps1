<#
    Script that scans the applocker policy for flawed path rules
    Authors: Alexander Van Daele, Simon Bockaert
    License: GNU General Public License v3.0
    Required Dependencies: None
    Optional Dependencies: None
#>

function Check-ApplockerFolder {
    <#
    .SYNOPSIS
    Writes customized output to a host.
    .DESCRIPTION
    The Write-Host cmdlet customizes output. You can specify the color of text by using
    the ForegroundColor parameter, and you can specify the background color by using the
    BackgroundColor parameter. The Separator parameter lets you specify a string to use to
    separate displayed objects. The particular result depends on the program that is
    hosting Windows PowerShell.
    #>
}

function Check-ApplockerFile {
    <#
    .SYNOPSIS
    Writes customized output to a host.
    .DESCRIPTION
    The Write-Host cmdlet customizes output. You can specify the color of text by using
    the ForegroundColor parameter, and you can specify the background color by using the
    BackgroundColor parameter. The Separator parameter lets you specify a string to use to
    separate displayed objects. The particular result depends on the program that is
    hosting Windows PowerShell.
    #>
}

function Check-ApplockerPath {
    <#
    .SYNOPSIS
    Writes customized output to a host.
    .DESCRIPTION
    The Write-Host cmdlet customizes output. You can specify the color of text by using
    the ForegroundColor parameter, and you can specify the background color by using the
    BackgroundColor parameter. The Separator parameter lets you specify a string to use to
    separate displayed objects. The particular result depends on the program that is
    hosting Windows PowerShell.
    #>
}

function Get-ApplockerPaths {
    <#
    .SYNOPSIS
    Returns the paths parsed from the path rules in Applocker.
    .DESCRIPTION
    Returns the paths parsed from the path rules in Applocker.
    #>
    $nodes = Get-AppLockerPolicy -Effective -Xml | Select-Xml -XPath "//AppLockerPolicy/RuleCollection/FilePathRule/Conditions/FilePathCondition"
    $all = $nodes | ForEach-Object {$tmp = $_.Node.Path -replace "%OSDRIVE%",$env:SystemDrive; [System.Environment]::ExpandEnvironmentVariables($tmp)}
    return $all
}

function Check-ApplockerFlaws {
    <#
    .SYNOPSIS
    Check the applocker policy for flaws.
    .DESCRIPTION
    Check the applocker policy for flaws.
    #>
    $all = Get-ApplockerPaths
    Write-Host $all
}
