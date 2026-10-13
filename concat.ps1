# Concatenate the ebook chapters in order, with a TOC at the front.
# Excludes the blueprint/editorial-plan file (not part of the manuscript).

$files = @(
    'sops-that-people-actually-use-opening-chapters.md',
    'sops-that-people-actually-use-chapters-03-04.md',
    'sops-that-people-actually-use-chapters-05-06.md',
    'sops-that-people-actually-use-chapters-07-08.md',
    'sops-that-people-actually-use-chapters-09-10.md',
    'sops-that-people-actually-use-chapters-11-12.md',
    'sops-that-people-actually-use-chapters-13-14.md',
    'sops-that-people-actually-use-chapters-15-16.md'
)

$out = 'sops-that-people-actually-use-full.md'

# Build TOC from chapter-level headings (## Chapter / ## Introduction / ## Part)
$toc = @('# Table of Contents', '')
foreach ($f in $files) {
    foreach ($line in (Get-Content $f)) {
        if ($line -match '^## (Introduction|Chapter|Part) — (.+)$') {
            $toc += "- $($matches[0] -replace '^## ','')"
        }
    }
}

$toc += @('', '---', '')

$parts = @($toc -join "`n")
foreach ($f in $files) {
    $parts += (Get-Content $f -Raw).TrimEnd() + "`n"
}

($parts -join "`n") | Set-Content $out -Encoding utf8
Write-Output "Wrote $out"
