$content = Get-Content 'C:\develop\AI-Generated-Projects\animewhere\specs\002-infinite-catalog-feed\checklists\requirements.md'
$checked = 0
$unchecked = 0
foreach ($line in $content) {
    if ($line -match '^\s*-\s*\[x\]' -or $line -match '^\s*-\s*\[X\]') {
        $checked++
    } elseif ($line -match '^\s*-\s*\[ \]') {
        $unchecked++
    }
}
Write-Output "Checked: $checked, Unchecked: $unchecked, Total: $($checked + $unchecked)"