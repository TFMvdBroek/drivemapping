Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()

######################################################################
#                section script configuration                        #
######################################################################

<#

   Add your internal Active Directory Domain name and custom network drives below

#>

$dnsDomainName= "ad.syncom.nl"

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "Z"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\Migration"
    Description="Migration"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "I"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\ISCO"
    Description="ISCO"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "P"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\PDF"
    Description="PDF"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "L"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\Library"
    Description="Library"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "A"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\Analysis"
    Description="Analysis"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "M"
    UNCPath= "\\synsvfs.ad.syncom.nl\fs\Microscope"
    Description="Microscope"
}

$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "G"
    UNCPath= "\\synbafs001.ad.syncom.nl\Data"
    Description="Data"
}



######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLetter):").Self.Name=$PSItem.Description
}

Stop-Transcript
