function Get-SMSWList {
    <#
    .SYNOPSIS
        Gets info on installed software
    .DESCRIPTION
        Gets information on installed software
    .NOTES
        Get-SMSWList | Ver. 5.0 | Shawn Murdock | 2022-11-28
    #>
    [cmdletbinding()]
    [alias('swlist')]
    [OutputType('My.SIObject')]
    Param(
        [string] $DisplayName = '*'
    )
    Begin {
        $Scopes = @{
            HKLM = 'All Users'
            HKCU = 'Current User'
        }
        $Architectures = @{
            $true  = '32-Bit'
            $false = '64-Bit'
        }
        $Scope = @{
            Name       = 'Scope'
            Expression = {
                $Scopes[$_.PSDrive.Name]
            }
        }
        $Architecture = @{
            Name       = 'Architecture'
            Expression = {$Architectures[$_.PSParentPath -like '*\WOW6432Node\*']}
        }
        $Values = 'AuthorizedCDFPrefix',
        'Comments',
        'Contact',
        'DisplayName',
        'DisplayVersion',
        'EstimatedSize',
        'HelpLink',
        'HelpTelephone',
        'InstallDate',
        'InstallLocation',
        'InstallSource',
        'Language',
        'ModifyPath',
        'NoModify',
        'PSChildName',
        'PSDrive',
        'PSParentPath',
        'PSPath',
        'PSProvider',
        'Publisher',
        'Readme',
        'Size',
        'SystemComponent',
        'UninstallString',
        'URLInfoAbout',
        'URLUpdateInfo',
        'Version',
        'VersionMajor',
        'VersionMinor',
        'WindowsInstaller',
        'Scope',
        'Architecture'
    }
    Process {
        $DefaultDisplaySet = 'DisplayName', 'DisplayVersion', 'Publisher', 'InstallDate'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $ScriptBlock = {
            $hashtable = @{}
            foreach ( $property in $this.psobject.properties.name ) {
                $hashtable[$property] = $this.$property
            }
            return $hashtable
        }
        $data = [System.Collections.Generic.List[psobject]]::new()
        $SWList = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction Ignore |
            Where-Object DisplayName |
            Where-Object { $_.DisplayName -like $DisplayName } |
            Select-Object -Property *, $Scope, $Architecture |
            Select-Object -Property $values |
            Sort-Object -Property DisplayName, Scope, Architecture #|
        #Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $visibleProperties -PassThru
        foreach ($item in $swlist) {
            $data.add([PSCustomObject]@{
                    DisplayName      = $item.DisplayName
                    DisplayVersion   = $item.DisplayVersion
                    VersionMinor     = $item.VersionMinor
                    Version          = $item.Version
                    VersionMajor     = $item.VersionMajor
                    Publisher        = $item.Publisher
                    Contact          = $item.Contact
                    Comments         = $item.Comments
                    Readme           = $item.Readme
                    InstallDate      = $item.InstallDate
                    Scope            = $item.Scope
                    Architecture     = $item.Architecture
                    HelpLink         = $item.HelpLink
                    EstimatedSize    = $item.EstimatedSize
                    Size             = $item.Size
                    InstallLocation  = $item.InstallLocation
                    InstallSource    = $item.InstallSource
                    UninstallString  = $item.UninstallString
                    WindowsInstaller = $item.WindowsInstaller
                })
        }
        $memberParam = @{
            MemberType = 'ScriptMethod'
            Name       = 'ToHashtable'
            Value      = $scriptBlock
        }
        $data | Add-Member @memberParam
        $data.PSObject.TypeNames.Insert(0, 'My.SIObject')
        $data | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        $data
    }
}
