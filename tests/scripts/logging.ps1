$Items = Get-ChildItem -LiteralPath "$ScriptRoot\logs" -Recurse
foreach ($Item in $Items) {
    $Item.Delete()
}

# $Items = Get-Item -LiteralPath "$ScriptRoot\logs\"
# $Items.Delete($true)