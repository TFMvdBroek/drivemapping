Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()

######################################################################
#                section script configuration                        #
######################################################################

<#

   Add your internal Active Directory Domain name and custom network drives below

#>

$dnsDomainName= "ad.syncom.nl"

$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000b2537f294aacaa469f151a8132bdce8b00000000020000000000106600000001000020000000d9c406bb9e107174f834bdc4ebe5720efc1c6966b7cfe074d40377552b3ac1ba000000000e80000000020000200000009a124f0cfaededa38c5216b23f62bc20bf8b2df4d7fae038d80c190d041315c010000000bcc45f14c856bbf27f7d240d8c99ad3240000000a8e2fd5e01fe0125c8bc84956c8ad813688779f10454e7988ec85b99ec7ec16582a3d3d8e58346cc3f1c821a00220792d1ca614aa5fad4149632576210bb7eac"
$Secure = ConvertTo-SecureString -String $Password
$Cred = New-Object System.Management.Automation.PsCredential('analyse',$Secure)

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

#Map Syncom drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Credential $cred -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLetter):").Self.Name=$PSItem.Description
}

#Map G drive
        New-PSDrive -PSProvider FileSystem -Name "G" -Root "\\synbafs001.ad.syncom.nl\Data" -Description "Data" -Persist -Scope global



Stop-Transcript
