function Can-Create-Subfile{
    param([string]$path = "")
    $success = $false
    Try {
        New-Item -Path $path\test.abc -ItemType file -ErrorAction Stop
        Remove-Item $path\test.abc -Force
        $success = $true
        }
    Catch{
        $success = $false
        }
    return $success
}

function Can-Create-File{
    param([string]$path = "")
    $success = $false
    Try {
        New-Item -Path $path -ItemType file -ErrorAction Stop
        Remove-Item $path -Force
        $success = $true
        }
    Catch{
        $success = $false
        }
    return $success
}

function Can-Create-Directory{
    param([string]$path = "")
    $success = $false
    Try {
        New-Item -Path $path -ItemType directory -ErrorAction Stop
        Remove-Item $path -Force
        $success = $true
        }
    Catch{
        $success = $false
        }
    return $success
}

function Can-Write-File{
    param([string]$path = "")
    Try { 
        [io.file]::OpenWrite($path).close()
        return $true
    }
    Catch { 
        return $false
    }
}


function Check-Applockerpath{
    param([string]$path = ".")
    # Translate env variables
    $path = [System.Environment]::ExpandEnvironmentVariables($path)
    # Does path contain a wildcard at the end? Aka is it a specific directory? C:\Temp\*
    if ($path -match "\\\*$"){
        $path = $path -replace "\\\*$", ""
    }
    # Ok removed trailing wildcard for directories -> now resolve further wildcards
    try{
        #Write-Host "Resolving $path..."
        $paths = Resolve-Path -Path $path -ErrorAction SilentlyContinue
    }
    catch
    {
        # resolve fails due to path not existing -> just check path
        #Write-Host "Resolve path error: $path $error"
        $paths = $path
    }
    $results = @()
    if ($paths -ne $null){
    #Write-Host "Checking $paths..."
    Foreach ($p in $paths){
        # File or directory?
        try{
            if(Test-Path -Path $p -PathType Container -ErrorAction Stop){ # directory
                if(Can-Create-Subfile -Path $p){
                    #Write-Host "I can create a subfile in directory $p"
                    $results += $p
                }
                else{
                }
            }
            else{
                if(Test-Path -Path $p -PathType Leaf -ErrorAction Stop){ # file
                    if (Can-Write-File -Path $p){
                        #Write-Host "I can edit file $p"
                        $results += $p
                    }
                    else{
                    }
                }
                else{
                # Does not exist
                    Write-Host "Directory or file $p does not exist"
                    if ($p -match ".*\\.*\..*$"){
                        # it's most likely a file
                        if (Can-Create-File -path $p){
                            $results += $p
                        }
                    }
                    else{
                        # just a lowly directory
                        if (Can-Create-Directory -path $p) {
                            $results += $p
                        }
                    }
                }
            }
        }
        catch{
            #Write-Host "Got here somehow: $p error: $error"
        }
    }
    }
    return $results
}

$nodes = Get-AppLockerPolicy -Effective -Xml | Select-Xml -XPath "//AppLockerPolicy/RuleCollection/FilePathRule/Conditions/FilePathCondition"
$all = $nodes | ForEach-Object {$tmp = $_.Node.Path -replace "%OSDRIVE%",$env:SystemDrive; [System.Environment]::ExpandEnvironmentVariables($tmp)}

Foreach ($p in $all){
    if($p -match "^C") {
        $result = Check-Applockerpath -path $p
        if ($result.count -gt 0) {
            Foreach ($r in $result){
                Write-Host "Vulnerable: $r"
            }
        }
    }
}
