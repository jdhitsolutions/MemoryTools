$config = New-PesterConfiguration
$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config