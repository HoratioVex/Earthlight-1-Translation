# subtract 0x80 from every word
# prepares for copying to VRAM uncompressed by Earthlight (SNES) tilemap loader

$files = Get-ChildItem -Path .\* -Include *.raw

foreach ($f in $files)
{
	$bytesraw = [System.IO.File]::ReadAllBytes($f.FullName)
	$pos = 0
	while ($pos -lt $bytesraw.Count) {
		$lo=$bytesraw[$pos]
		$hi=$bytesraw[$pos+1]
		$word=([int]$hi -shl 8) -bor $lo
				
		if ($word -lt 0x80) {
			write-host "Word too small, skipping at offset $pos"
			$pos=$pos+2
			continue
		}
		$word=$word-0x80
		$lo=$word -band 0xFF
		$hi=($word -band 0xFF00) -shr 8
		$bytesraw[$pos]=$lo
		$bytesraw[$pos+1]=$hi
		$pos=$pos+2
	}
	
	$bytesready = $f.DirectoryName+"\"+$f.Basename+".bin"
	[System.IO.File]::WriteAllBytes($bytesready, $bytesraw)
	
	
}
write-host "Done"