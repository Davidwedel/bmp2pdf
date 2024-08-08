# Check if ImageMagick is installed
if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
    Write-Host "ImageMagick (magick) could not be found. Please install it first."
    exit 1
}

# Check for correct number of arguments
if ($args.Count -ne 2) {
    Write-Host "Usage: .\script.ps1 <input_directory> <output_directory>"
    exit 1
}

# Set input and output directories
$input_directory = $args[0]
$output_directory = $args[1]

# Check if input directory exists
if (-not (Test-Path -Path $input_directory -PathType Container)) {
    Write-Host "Input directory $input_directory does not exist."
    exit 1
}

# Check if output directory exists, if not, create it
if (-not (Test-Path -Path $output_directory -PathType Container)) {
    New-Item -ItemType Directory -Path $output_directory -Force
    if (-not (Test-Path -Path $output_directory -PathType Container)) {
        Write-Host "Failed to create output directory $output_directory."
        exit 1
    }
}

# Loop through all .bmp files in the input directory
$bmp_files = Get-ChildItem -Path $input_directory -Filter *.bmp

if ($bmp_files.Count -eq 0) {
    Write-Host "No .bmp files found in the input directory $input_directory."
    exit 1
}

foreach ($bmp_file in $bmp_files) {
    # Get the base name of the file (without extension)
    $base_name = [System.IO.Path]::GetFileNameWithoutExtension($bmp_file.Name)

    # Convert .bmp file to .pdf and place in the output directory
    $output_pdf = Join-Path -Path $output_directory -ChildPath "$base_name.pdf"
    magick -density 150 $bmp_file.FullName -compress jpeg $output_pdf

    # Check if the conversion was successful
    if ($?) {
        Write-Host "Converted $($bmp_file.FullName) to $output_pdf successfully."
        # Remove the .bmp file
        Remove-Item -Path $bmp_file.FullName -Force
        if ($?) {
            Write-Host "Deleted $($bmp_file.FullName) successfully."
        } else {
            Write-Host "Failed to delete $($bmp_file.FullName)."
        }
    } else {
        Write-Host "Failed to convert $($bmp_file.FullName) to $output_pdf."
    }
}

