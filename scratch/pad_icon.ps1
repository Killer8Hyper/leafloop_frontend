Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Flutter-Projects\leafloop_frontend\assets\images\logo\LeafLoop2.png"
$outputPath = "c:\Flutter-Projects\leafloop_frontend\assets\images\logo\LeafLoop2_foreground.png"

$original = [System.Drawing.Image]::FromFile($inputPath)
Write-Host "Original size: $($original.Width)x$($original.Height)"

# Create a new canvas (1024x1024) with transparent background
$canvasSize = 1024
$bitmap = New-Object System.Drawing.Bitmap($canvasSize, $canvasSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.Clear([System.Drawing.Color]::Transparent)

# 25% padding on each side = logo occupies 50% of canvas (safe zone for adaptive icons)
$padding = [int]($canvasSize * 0.22)
$logoSize = $canvasSize - (2 * $padding)

$graphics.DrawImage($original, $padding, $padding, $logoSize, $logoSize)

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Saved padded foreground to: $outputPath"

$graphics.Dispose()
$bitmap.Dispose()
$original.Dispose()
