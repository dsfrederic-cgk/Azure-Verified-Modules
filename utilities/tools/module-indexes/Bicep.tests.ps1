[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Enter the full path to the CSV file.')]
    [ValidateNotNullOrEmpty()]
    [Alias('Path')]
    [string]$CsvFilePath
)

BeforeAll {
    $csvContent = Import-Csv -Path $CsvFilePath
    $csvHeaders = $csvContent[0].PSObject.Properties.Name

    $singularExceptions = @(
        'redis',
        'address'
    )

}

Describe 'Tests for Module Indexes' {

    Context "Validating the $(Split-Path $CsvFilePath -Leaf) file" {

        It 'CSV file must not be empty' {
            $csvContent | Should -Not -BeNullOrEmpty
        }

        if ($CsvFilePath -match 'ResourceModules') {
            It 'Should contain exactly the columns required for resource modules' {
                $requiredColumns = @(
                    'ProviderNamespace', 'ResourceType', 'ModuleDisplayName', 'ModuleName', 'ModuleStatus',
                    'RepoURL', 'PublicRegistryReference', 'TelemetryIdPrefix', 'PrimaryModuleOwnerGHHandle',
                    'PrimaryModuleOwnerDisplayName', 'SecondaryModuleOwnerGHHandle', 'SecondaryModuleOwnerDisplayName',
                    'ModuleOwnersGHTeam', 'ModuleContributorsGHTeam', 'Description', 'Comments', 'FirstPublishedIn'
                )
                $csvHeaders | Should -Be $requiredColumns
            }
        } elseif ($CsvFilePath -match 'PatternModules') {
            It 'Should contain exactly the columns required for pattern modules' {
                $requiredColumns = @(
                    'ModuleDisplayName', 'ModuleName', 'ModuleStatus',
                    'RepoURL', 'PublicRegistryReference', 'TelemetryIdPrefix', 'PrimaryModuleOwnerGHHandle',
                    'PrimaryModuleOwnerDisplayName', 'SecondaryModuleOwnerGHHandle', 'SecondaryModuleOwnerDisplayName',
                    'ModuleOwnersGHTeam', 'ModuleContributorsGHTeam', 'Description', 'Comments', 'FirstPublishedIn'
                )
                $csvHeaders | Should -Be $requiredColumns
            }
        }

        It 'Should have at least 1 record' {
            $csvContent.Length | Should -BeGreaterOrEqual 1
        }
    }

    Context 'Looking for empty fields' {
        It "Should not have any missing values in the 'ModuleName' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.ModuleName | Should -Not -BeNullOrEmpty -Because "ModuleName is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'ModuleDisplayName' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.ModuleDisplayName | Should -Not -BeNullOrEmpty -Because "ModuleDisplayName is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'RepoURL' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.RepoURL | Should -Not -BeNullOrEmpty -Because "RepoURL is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'PublicRegistryReference' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.PublicRegistryReference | Should -Not -BeNullOrEmpty -Because "PublicRegistryReference is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'TelemetryIdPrefix' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.TelemetryIdPrefix | Should -Not -BeNullOrEmpty -Because "TelemetryIdPrefix is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'ModuleOwnersGHTeam' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.ModuleOwnersGHTeam | Should -Not -BeNullOrEmpty -Because "ModuleOwnersGHTeam is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'ModuleContributorsGHTeam' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.ModuleContributorsGHTeam | Should -Not -BeNullOrEmpty -Because "ModuleContributorsGHTeam is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
        It "Should not have any missing values in the 'Description' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.Description | Should -Not -BeNullOrEmpty -Because "Description is a required field. In line #$lineNumber, this is empty. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }

        It "should have a valid URL in the 'RepoURL' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.RepoURL | Should -Match '^(http|https)://.*' -Because "RepoURL should be a valid URL. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
    }

    Context 'Looking for duplicate entries' {
        It "Should not have any duplicate values in the 'ModuleName' column" {
            $duplicates = $csvContent | Group-Object -Property ModuleName | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's ModuleName should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'ModuleDisplayName' column" {
            $duplicates = $csvContent | Group-Object -Property ModuleDisplayName | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's ModuleDisplayName should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'RepoURL' column" {
            $duplicates = $csvContent | Group-Object -Property RepoURL | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's RepoURL should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'PublicRegistryReference' column" {
            $duplicates = $csvContent | Group-Object -Property PublicRegistryReference | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's PublicRegistryReference should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'TelemetryIdPrefix' column" {
            $duplicates = $csvContent | Group-Object -Property TelemetryIdPrefix | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's TelemetryIdPrefix should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'ModuleOwnersGHTeam' column" {
            $duplicates = $csvContent | Group-Object -Property ModuleOwnersGHTeam | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's ModuleOwnersGHTeam should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'ModuleContributorsGHTeam' column" {
            $duplicates = $csvContent | Group-Object -Property ModuleContributorsGHTeam | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's ModuleContributorsGHTeam should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
        It "Should not have any duplicate values in the 'Description' column" {
            $duplicates = $csvContent | Group-Object -Property Description | Where-Object Count -GT 1
            $duplicates | Should -BeNullOrEmpty -Because "each module's Description should be unique. This is a duplicate: ""$($duplicates.Name)"""
        }
    }

    Context 'ModuleName' {
        if ($CsvFilePath -match 'ResourceModules') {
            It "Should start with 'avm/res/'" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $item.ModuleName | Should -Match "^avm/res/.*" -Because "ModuleName should start with 'avm/res/'. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item.ModuleName)"""
                    $lineNumber++
                }
            }

            It "First segment of ModuleName should be derived from the ProviderNamespace" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $firstSegmentFromRP = ($item.ProviderNamespace -replace 'Microsoft.','').ToLower()
                    $firstSegmentInModuleName = ($item.ModuleName -split '/')[2] -replace '-',''
                    # $secondSegment = ((Split-CamelCase -inputString $item.ResourceType) -join "-").ToLower()

                    # $expectedModuleName = "avm/res/" + $firstSegment + '/' + $secondSegment
                    $firstSegmentInModuleName | Should -BeLike "$firstSegmentFromRP"  -Because "the first segment of ModuleName should be derived from the ProviderNamespace. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item.ModuleName)"""
                    $lineNumber++
                }
            }
            # It "Second segment of ModuleName should be derived from the ResourceType" {
            #     $lineNumber = 2
            #     foreach ($item in $csvContent) {
            #         if ($item.ModuleName -notin $singularExceptions) {
            #             $lastSegmentOfModuleName = ($item.ModulName -split '/')[-1] -replace '-',''
            #         }
            #         elseif ($item.ModuleName -in $singularExceptions) {

            #         }
            #         $firstSegmentFromRT = ($item.ResourceType -replace 'Microsoft.','').ToLower()
            #         $firstSegmentInModuleName = ($item.ModuleName -split '/')[2] -replace '-',''
            #         # $secondSegment = ((Split-CamelCase -inputString $item.ResourceType) -join "-").ToLower()

            #         # $expectedModuleName = "avm/res/" + $firstSegment + '/' + $secondSegment
            #         $firstSegmentInModuleName | Should -BeLike $firstSegmentFromRT  -Because "the first segment of ModuleName should be derived from the ResourceType. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item.ModuleName)"""
            #         $lineNumber++
            #     }
            # }
            It "Should be in singular form" {
                $lineNumber = 2
                foreach ($item in $csvContent) {

                    $lastWord = (($item.ModuleName -split '/')[-1] -split '-')[-1]
                    if ($lastWord -notin $singularExceptions) {
                        $item.ModuleName | Should -Not -Match "s$" -Because "ModuleName should be in singular form. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item.ModuleName)"""
                    }
                    $lineNumber++
                }
            }
        }
    }

    Context 'TelemetryId' {
        BeforeAll {

        }

        It 'Telemetry ID prefix should be shorter than 49 characters' {
            foreach ($item in $csvContent) {
                $item.TelemetryIdPrefix.Length | Should -BeLessOrEqual 49 -Verbose -Because "deployments names must be under 64 characters. To keep the entire deployment name under 64 characters, $($item.TelemetryIdPrefix) should be shorter than 49"
            }
        }

        if ($CsvFilePath -match 'Bicep') {
            if ($CsvFilePath -match 'ResourceModules') {
                It 'Telemetry ID prefix should start with "46d3xbcp.res."' {
                    $lineNumber = 2
                    foreach ($item in $csvContent) {
                        $item.TelemetryIdPrefix | Should -Match '^46d3xbcp.res.*$' -Because "TelemetryIdPrefix should start with '46d3xbcp.res.'. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.TelemetryIdPrefix)"""
                    }
                    $lineNumber++
                }
            }
            elseif ($CsvFilePath -match 'PatternModules') {
                It 'Telemetry ID prefix should start with "46d3xbcp.ptn."' {
                    $lineNumber = 2
                    foreach ($item in $csvContent) {
                        $item.TelemetryIdPrefix | Should -Match '^46d3xbcp.ptn.*$' -Because "TelemetryIdPrefix should start with '46d3xbcp.ptn.'. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.TelemetryIdPrefix)"""
                    }
                    $lineNumber++
                }
            }

        }
    }

    Context 'RepoURL' {
        It "Should have a valid URL in the 'RepoURL' column" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.RepoURL | Should -Match '^(http|https)://.*' -Because "RepoURL should be a valid URL. In line #$lineNumber, this is invalid. The following values have been provided: ""$($item)"""
                $lineNumber++
            }
        }
    }

    Context 'PublicRegistryReference' {
        if ($CsvFilePath -match 'Bicep') {
            It "Should have a valid Public Bicep Regisrtry reference in the 'PublicRegistryReference' column" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $item.PublicRegistryReference | Should -Match "^br/public:$($item.ModuleName):X.Y.Z$" -Because "PublicRegistryReference should point to the Public Bicep Registry. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.PublicRegistryReference)"""
                    $lineNumber++
                }
            }
        }
        elseif ($CsvFilePath -match 'Terraform') {
            It "Should have a valid Terraform registry reference in the 'PublicRegistryReference' column" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $item.PublicRegistryReference | Should -Match "^https://registry.terraform.io/modules/Azure/$($item.ModuleName)/azurerm/latest$" -Because "PublicRegistryReference should be a valid URL. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.PublicRegistryReference)"""
                    $lineNumber++
                }
            }
        }
    }

    Context "ModuleOwnersGHTeam" {
        if ($CsvFilePath -match 'Bicep') {
            It "Should have a valid GitHub team name in the 'ModuleOwnersGHTeam' column" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $teamName = $item.ModuleName -replace '-','' -replace '/','-'
                    $item.ModuleOwnersGHTeam | Should -Match "^@Azure/$teamName-module-owners-bicep$" -Because "ModuleOwnersGHTeam should follow the naming convention. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.ModuleOwnersGHTeam)"""
                    $lineNumber++
                }
            }
        }
        elseif ($CsvFilePath -match 'Terraform') {
            It "Should have a valid GitHub team name in the 'ModuleOwnersGHTeam' column" {
                $lineNumber = 2
                foreach ($item in $csvContent) {
                    $item.ModuleOwnersGHTeam | Should -Match '^@Azure/avm-.*-module-owners-tf$' -Because "ModuleOwnersGHTeam should follow the naming convention. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.ModuleOwnersGHTeam)"""
                    $lineNumber++
                }
            }
        }
    }

    Context "ModuleStatus" {
        It "Should have a valid value in the 'ModuleStatus' column" {
            $allowedValues = @(
                    'Proposed :new:','Available :green_circle:','Orphaned :eyes:'
                )
            $lineNumber = 2
            foreach ($item in $csvContent) {
                $item.ModuleStatus | Should -BeIn $allowedValues -Because "ModuleStatus should be one of the following: 'Proposed :new:', 'Available :green_circle:', 'Orphaned :eyes:'. In line #$lineNumber, this is invalid. The following value have been provided: ""$($item.ModuleStatus)"""
                $lineNumber++
            }
        }

        It "Should have a PrimaryModuleOwnerGHHandle for 'Available' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Available :green_circle:') {
                    $item.PrimaryModuleOwnerGHHandle | Should -Not -BeNullOrEmpty -Because "PrimaryModuleOwnerGHHandle is a required field for 'Available' modules. This should have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "Should have a PrimaryModuleOwnerDisplayName for 'Available' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Available :green_circle:') {
                    $item.PrimaryModuleOwnerDisplayName | Should -Not -BeNullOrEmpty -Because "PrimaryModuleOwnerDisplayName is a required field for 'Available' modules. This should have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "PrimaryModuleOwnerGHHandle should be empty for 'Orphaned' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Orphaned :eyes:') {
                    $item.PrimaryModuleOwnerGHHandle | Should -BeNullOrEmpty -Because "PrimaryModuleOwnerGHHandle field must be empty for 'Orphaned' modules. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "PrimaryModuleOwnerDisplayName should be empty for 'Orphaned' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Orphaned :eyes:') {
                    $item.PrimaryModuleOwnerDisplayName | Should -BeNullOrEmpty -Because "PrimaryModuleOwnerDisplayName field must be empty for 'Orphaned' modules. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "SecondaryModuleOwnerGHHandle should be empty for 'Orphaned' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Orphaned :eyes:') {
                    $item.SecondaryModuleOwnerGHHandle | Should -BeNullOrEmpty -Because "SecondaryModuleOwnerGHHandle field must be empty for 'Orphaned' modules. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "SecondaryModuleOwnerDisplayName should be empty for 'Orphaned' modules" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.ModuleStatus -eq 'Orphaned :eyes:') {
                    $item.SecondaryModuleOwnerDisplayName | Should -BeNullOrEmpty -Because "SecondaryModuleOwnerDisplayName field must be empty for 'Orphaned' modules. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "Should not have a SecondaryModuleOwnerDisplayName if the PrimaryModuleOwnerDisplayName is empty" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.PrimaryModuleOwnerDisplayName -eq '') {
                    $item.SecondaryModuleOwnerDisplayName | Should -BeNullOrEmpty -Because "SecondaryModuleOwnerDisplayName should be empty if PrimaryModuleOwnerDisplayName is empty. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }

        It "Should not have a SecondaryModuleOwnerGHHandle if the PrimaryModuleOwnerGHHandle is empty" {
            $lineNumber = 2
            foreach ($item in $csvContent) {
                if ($item.PrimaryModuleOwnerGHHandle -eq '') {
                    $item.SecondaryModuleOwnerGHHandle | Should -BeNullOrEmpty -Because "SecondaryModuleOwnerGHHandle should be empty if PrimaryModuleOwnerGHHandle is empty. This should not have a value in line #$lineNumber"
                }
                $lineNumber++
            }
        }
    }
}
