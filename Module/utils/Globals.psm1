#Global values
function Get-Globals{
    $Commcellglobals = @{}
    $Commcellglobals.Add("commcellId", 2)
    $Commcellglobals.Add("DefaultSubclient","default")

    return $Commcellglobals
}