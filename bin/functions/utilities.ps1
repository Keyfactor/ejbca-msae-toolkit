<# Helper functions designed to be included in other functions

- These functions should be very simple
- Logging should not be performed directly in this function
#>

$LoggerFunctions = [WriteLog]::New($ToolBoxConfig.LogDirectory, $ToolBoxConfig.LogFiles.Main, $ToolBoxConfig.LogLevel)

function Convert-PromptReponseBool {
    <#
    .Synopsis
        Convert message box response to boolean
    .Description
        Message boxes return integer values. This function converts certain respones, like Yes/No, to True/False. 
        This is helpful when evaluting responses in condition statements.

        Refer to the following for the available DialogResult Enums:
        https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.dialogresult?view=windowsdesktop-8.0
    .Parameter Value
        Integer to convert with Switch condition
    .Example
        $Answer | Convert-PromptResponseBool  
    #>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline)][int]$Value
    )
    process {
        switch ([int]$Value) {
            1 {$true}
            2 {$false}
            6 {$true}
            7 {$false}
        }
    }
} 

function Convert-Slugify{
    <#
    .Synopsis
        Convert string to slug
    .Description
        Change all characters to lowercase and replace whitespaces with underscores
    .Parameter String
        String to convert
    .Example
        "Slugify Conversion" | Convert-KFSlugify
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline)][String]$String
    )
    process {
        $String = $String.ToLower()
        $String.Replace(' ','_')
    }
}

function Out-TableString {
    <#
    .Synopsis
        Creates string output of formatted table
    .Description
        Formats values as table and converts to string value. Intended for log and console output.
    .Parameter Table
        Object to format
    .Example
        $Table | Out-TableString
    #>
    param(
        [Parameter(Mandatory,ValueFromPipeline)][Object]$Object,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Switch]$Table,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Boolean]$HideTableHeaders=$true
    )
    process {
        if($Table){
            "`n$(($Object|Format-Table -HideTableHeaders -AutoSize|Out-String).Trim())"
        } else {
            "`n$(($Object|Format-List|Out-String).Trim())"
        }
    }
}

function Test-ParentDomain {
    <#
    .Synopsis
        Tests if current domain is Parent domain
    .Description
        Tests if current domain is Parent domain and outputs boolean value if DnsRoot and ParentDomain match
    .Example
        Test-ParentDomain
    #>
    $CurrentDomain = (Get-ADDomain -Current LocalComputer)
    if($CurrentDomain.DnsRoot -eq $CurrentDomain.ParentDomain){
        return $True
    } else {
        return $False
    }
}

function Test-WhiteSpace {
    param(
        [Parameter(Mandatory)][String]$Message,
        [Parameter(Mandatory)][String]$Value
    )

    $LoggerFunctions.Logger = "KF.Toolkit.Function.TestWhiteSpace"

    if($Value.Contains(' ')){
        $ValueTrimmed = $Value.Replace(' ','-')

        # Prompt for name change to remove white spaces
        $ResponseNameChange = Read-HostChoice `
                -Message "$($Message -f $ValueTrimmed)?" `
                -ReturnBool
        #$ResponseNameChange = Read-PromptYesNo -Message $($Message -f $ValueTrimmed) -Color Yellow
        if($ResponseNameChange){
            return $ValueTrimmed
        } else {
            $LoggerFunctions.Warn("The user chose not to provide a name without white spaces or let the tool automatically change it.")
            throw "User chose not to provide a valid name."
        }
    }
    return $Value
}

function Get-WinErrorHex {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][String]$Message
    )
    process{

        $ErrorHexSearch = $Message.Substring($Message.IndexOf("0x"))
        $ErrorMessageSearch = $Message.Substring(0,$Message.IndexOf("0x"))
        $ErrorRecord = [PSCustomObject]@{
            ErrorCode = $ErrorHexSearch.Split()[0]
            ErrorMessage = $ErrorMessageSearch.Substring($Message.LastIndexOf(":")+1).Trim()
        }

        return $ErrorRecord
    }
}



