<# 
.SYNOPSIS 
    PATH Environment Variable Cleaner 
.DESCRIPTION 
    This script will scan your PATH environment variable
    for nonexistent directory references and remove
    them as appropriate.
.PARAMETER targetUser
    Boolean parameter which indicates if the user-specific
    version of the PATH variable, as opposed to the
    machine-wide version, should be targeted. By default,
    this value is false, indicating that the machine-wide
    PATH value will be targeted.
.LINK 
    https://github.com/stocka/Windows-Utilities
#>  
param([boolean]$targetUser = $FALSE)

# Make sure generics are loaded
Add-Type -AssemblyName System.Core

# Figure out if we're targeting the user or machine
# version of this variable.
if( $targetUser ) {
    Write-Host 'Editing user PATH variable.'
    $target = "User"
}
else {
    Write-Host 'Editing machine PATH variable.'
    $target = "Machine"
}
Write-Host ""

# Get the array of environment variables
$env = [Environment]::GetEnvironmentVariable("Path", $target)
$envs = $env.split(";")

# Create our List, which we're using to preserve order.
$type = ("System.Collections.Generic.List"+'`'+"1") -as "Type"
$type = $type.MakeGenericType( @( ("system.string" -as "Type") ) )
$processedEnvs = [Activator]::CreateInstance($type)

foreach ($dir in $envs) {

    if ( Test-Path $dir ) {
        if( -not $processedEnvs.Contains($dir) ) {
            Write-Host $dir 'was found.'
            $processedEnvs.Add($dir) | out-null
        } 
        else {
            Write-Host $dir 'was found, but is a duplicate.'
        }
    } 
    else {
        Write-Host $dir 'was not found.'
    }
}

# Now build our list
$processedEnvStr = "";
foreach ($dir in $processedEnvs) {
    $processedEnvStr += $dir
    $processedEnvStr += ';'
}

# Remove trailing ;
if ($processedEnvStr.length -gt 0) {
    $processedEnvStr = $processedEnvStr.TrimEnd(';')
}

Write-Host ''
Write-Host 'New PATH value:' $processedEnvStr

# Now actually set it.
[Environment]::SetEnvironmentVariable("Path", $processedEnvStr, $target)
