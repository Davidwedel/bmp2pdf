#!/bin/bash

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "ImageMagick (convert) could not be found. Please install it first."
    exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# Set input and output directories
input_directory="$1"
output_directory="$2"

# Check if input directory exists
if [ ! -d "$input_directory" ]; then
    echo "Input directory $input_directory does not exist."
    exit 1
fi

# Check if output directory exists, if not, create it
if [ ! -d "$output_directory" ]; then
    mkdir -p "$output_directory"
    if [ $? -ne 0 ]; then
        echo "Failed to create output directory $output_directory."
        exit 1
    fi
fi

# Loop through all .bmp files in the input directory
for bmp_file in "$input_directory"/*.bmp; do
    # Check if there are any .bmp files
    if [ ! -e "$bmp_file" ]; then
        echo "No .bmp files found in the input directory $input_directory."
        exit 1
    fi

    # Get the base name of the file (without extension)
    base_name=$(basename "$bmp_file" .bmp)

    # Convert .bmp file to .pdf and place in the output directory
    magick -density 150 "$bmp_file" -compress jpeg "$output_directory/${base_name}.pdf"

    # Check if the conversion was successful
    if [ $? -eq 0 ]; then
        echo "Converted $bmp_file to $output_directory/${base_name}.pdf successfully."
        # Remove the .bmp file
        rm "$bmp_file"
        if [ $? -eq 0 ]; then
            echo "Deleted $bmp_file successfully."
        else
            echo "Failed to delete $bmp_file."
        fi
    else
        echo "Failed to convert $bmp_file to $output_directory/${base_name}.pdf."
    fi
done

