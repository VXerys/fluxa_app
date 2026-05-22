$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match '\.withOpacity\(') {
        $newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
        Set-Content $file.FullName $newContent -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}
Write-Host "Done!"
