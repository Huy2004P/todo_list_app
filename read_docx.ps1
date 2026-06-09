Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$filePath = 'd:\TodoApp\todo_list_app\BaoCao_ITMastery_MVP_10Ngay .docx'
$zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$stream = $entry.Open()
$reader = New-Object -TypeName System.IO.StreamReader -ArgumentList $stream
$xml = $reader.ReadToEnd()
$reader.Dispose()
$stream.Dispose()
$zip.Dispose()
$xml = $xml -replace '<[^>]+>', ' '
$xml = [System.Text.RegularExpressions.Regex]::Replace($xml, '\s+', ' ')
$xml.Trim() | Out-File -FilePath 'd:\TodoApp\todo_list_app\docx_content.txt' -Encoding UTF8
Write-Host "Done! Saved to docx_content.txt"
