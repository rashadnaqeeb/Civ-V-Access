param(
    [Parameter(Mandatory)] [string]$Path,
    [Parameter(Mandatory)] [double]$X,
    [Parameter(Mandatory)] [double]$Y,
    [Parameter(Mandatory)] [double]$W,
    [Parameter(Mandatory)] [double]$H,
    [string]$Out = "$env:TEMP\crop.png"
)
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($Path)
Write-Output "source $($img.Width)x$($img.Height)"
$rect = New-Object System.Drawing.Rectangle ([int]($img.Width * $X)), ([int]($img.Height * $Y)), ([int]($img.Width * $W)), ([int]($img.Height * $H))
$bmp = New-Object System.Drawing.Bitmap $img
$crop = $bmp.Clone($rect, $bmp.PixelFormat)
$crop.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose(); $bmp.Dispose(); $img.Dispose()
Write-Output "wrote $Out"
