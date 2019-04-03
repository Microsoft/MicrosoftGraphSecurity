<#
.Synopsis
   Creates a new Threat Intelligence Indicator in Microsoft Graph Security.

.DESCRIPTION
   Creates a new Threat Intelligence Indicator(s) in Microsoft Graph Security.

   Each indicator must contain at least one email, file, or network observable.

   For string collection properties supply the data in the format of "value1","Value2" or value1,value2

.EXAMPLE
   New-GraphSecurityTiIndicator -action block -description "File hash for cyrptominer.exe" -expirationDateTime 01/02/2020 -requiredProduct "Azure Sentinel" -threatType CyrptoMining -tlpLevel red -fileHashType SHA256 -fileHashValue 2D6BDFB341BE3A6234B24742377F93AA7C7CFB0D9FD64EFA9282C87852E57085

    This will create a new indicator to block based on file hash and expires 01/01/2020.

.EXAMPLE
   (Import-Csv tiIndicators.csv) | New-GraphSecurityTiIndicator

    This will create a new indicator for each item in the CSV.  The CSV must have the required properties that match the API property names.

.FUNCTIONALITY
   New-GraphSecurityTiIndicator is intended to function as a mechanism for creating TI Indicators using Microsoft Graph Security.
#>
function New-GraphSecurityTiIndicator {
    param
    (
        #Specifies the API Version
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$Version = "Beta",

        # Base Object
        # The action to apply if the indicator is matched from within the targetProduct security tool.
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateSet("unknown", "allow", "block", "alert")]
        [string]$action,

        # Name or alias of the activity group (attacker) this indicator is attributed to.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$activityGroupNames,

        # A catchall area into which extra data from the indicator not covered by the other tiIndicator properties
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$additionalInformation,

        # An integer representing the confidence the data within the indicator accurately identifies malicious behavior. Acceptable values are 0 – 100 with 100 being the highest.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$confidence,

        # Brief description (100 characters or less) of the threat represented by the indicator.
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$description,

        # he area of the Diamond Model in which this indicator exists.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateSet("unknown", "adversary", "capability", "infrastructure", "victim")]
        [string]$diamondModel,

        # DateTime string indicating when the Indicator expires.
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$expirationDateTime,

        # An identification number that ties the indicator back to the indicator provider’s system (e.g. a foreign key).
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$externalId,

        # Used to deactivate indicators within system.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateSet($true, $false)]
        [boolean]$isActive = $false,

        # A JSON array of strings that describes which point or points on the Kill Chain this indicator targets.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$killChain,

        # Scenarios in which the indicator may cause false positives. This should be human-readable text.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$knownFalsePositives,

        # The last time the indicator was seen.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$lastReportedDateTime,

        # The malware family name associated with an indicator if it exists.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$malwareFamilyNames,

        # Determines if the indicator should trigger an event that is visible to an end-user.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateSet($true, $false)]
        [boolean]$passiveOnly,

        # An integer representing the severity of the malicious behavior identified by the data within the indicator.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateRange(0, 5)]
        [int]$severity,

        # A JSON array of strings that stores arbitrary tags/keywords.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$tags,

        # Target product for the TI indicator
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateSet("Azure Sentinel")]
        [string]$targetProduct = "Azure Sentinel",

        # Each indicator must have a valid Indicator Threat Type.
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateSet("Botnet", "C2", "CryptoMining", "Darknet", "DDoS", "MaliciousUrl", "Malware", "Phishing", "Proxy", "PUA", "WatchList")]
        [string]$threatType,

        # Traffic Light Protocol value for the indicator.
        [Parameter(ParameterSetName = 'Email', Mandatory = $true)]
        [Parameter(ParameterSetName = 'File', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [ValidateSet("unknown", "white", "green", "amber", "red")]
        [string]$tlpLevel

        # Email observables
        # The type of text encoding used in the email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailEncoding,

        # The language of the email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailLanguage,

	    # Recipient email address.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailRecipient,

        # Email address of the attacker|victim.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailSenderAddress,

        # Displayed name of the attacker|victim.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailSenderName,
	    
        # Domain used in the email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailSourceDomain,

	    # Source IP address of email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailSourceIpAddress,

        # Subject line of email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailSubject,
        
        # X-Mailer value used in the email.
        [Parameter(ParameterSetName = 'Email', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$emailXMailer,

        # File Observables
        # DateTime when the file was compiled.
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileCompileDateTime,

        #DateTime when the file was created.
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileCreatedDateTime,

        # The type of hash stored in fileHashValue
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateSet("unknown", "sha1", "sha256", "md5", "authenticodeHash256", "lsHash", "ctph")]
        [string]$fileHashType,
        
        # The file hash value.
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileHashValue,

        # Mutex name used in file-based detections
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileMutexName,

        # Name of the file if the indicator is file-based
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileName,

        # The packer used to build the file in question.
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$filePacker, 

        # Path of file indicating compromise. May be a Windows or *nix style path
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$filePath,

        # Size of the file in bytes
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int64]$fileSize,

        # Text description of the type of file.
        [Parameter(ParameterSetName = 'File', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$fileType,

        # Network Observables
        # Domain name associated with this indicator.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$domainName,

        # CIDR Block notation representation of the network referenced
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkCidrBlock,

        # The destination autonomous system identifier of the network referenced 
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int32]]$networkDestinationAsn,

        # CIDR Block notation representation of the destination network
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkDestinationCidrBlock,

        # IPv4 IP address destination.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkDestinationIPv4,

        # IPv6 IP address destination.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkDestinationIPv6,

        # TCP port destination. 
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int32]$networkDestinationPort,

        # IPv4 IP address.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkIPv4,

        # IPv6 IP address.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkIPv6,

        # TCP port
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int32]$networkPort,

        # Decimal representation of the protocol field in the IPv4 header.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int32]$networkProtocol, 

        # The source autonomous system identifier of the network referenced
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int32]$networkSourceAsn,

        # CIDR Block notation representation of the source network
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkSourceCidrBlock,

        # IPv4 IP Address source.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkSourceIPv4,

        # IPv6 IP Address source.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$networkSourceIPv6,

        # TCP port source.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int32]$networkSourcePort,

        #Uniform Resource Locator. This URL must comply with RFC 1738.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$url,

        # User-Agent string from a web request that could indicate compromise.
        [Parameter(ParameterSetName = 'Network', Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$userAgent

    )

    Begin {

        Try {Test-GraphSecurityAuthToken}
        Catch {Throw $_}

        #Temp - Stop if Version is 1.0
        if($Version -ne "Beta"){
            Write-Error "Beta is only supported right now"
            break
        }
    }
    Process {
        #code for check if default param set
        
        try {
            # Fetch the item by its id
            $resource = "security/tiIndicators"
            $uri = "https://graph.microsoft.com/$Version/$($resource)"
            $response = Invoke-RestMethod -Uri $uri -Headers $GraphSecurityAuthHeader -Method POST
            Write-Verbose "Calling: $uri"
        }
        catch {
            $ex = $_.Exception
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Verbose "Response content:`n$responseBody"
            Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"

            break
        }
        $response

    }
    End {

        # Nothing to See Here

    }
}