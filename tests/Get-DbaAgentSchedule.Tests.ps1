$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance','Schedule','SqlCredential','EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    BeforeAll{
        $schedule = New-DbaAgentSchedule -SqlInstance $script:instance2 -Schedule dbatoolsci_MonthlyTest -FrequencyType Monthly -FrequencyInterval 10 -FrequencyRecurrenceFactor 1 -Force
    }
    Afterall{
        $schedule = Get-DbaAgentSchedule -SqlInstance $script:instance2 -schedule dbatoolsci_MonthlyTest
        $Schedule.DROP()
    }

    Context "Gets the list of Schedules" {
        $results = Get-DbaAgentSchedule -SqlInstance $script:instance2
        It "Results are not empty" {
            $results | Should Not Be $Null
        }
    }
    Context "Gets a single Schedule" {
        $results = Get-DbaAgentSchedule -SqlInstance $script:instance2 -Schedule dbatoolsci_MonthlyTest
        It "Results are not empty" {
            $results | Should Not Be $Null
        }
        It "Should have the name MonthlyTest" {
            $results.schedulename | Should Be "dbatoolsci_MonthlyTest"
        }
        It "Should have a frequency of 10" {
            $results.FrequencyInterval | Should Be 10
        }
        It "Should be enabled" {
            $results.isenabled | Should Be $true
        }
    }
}