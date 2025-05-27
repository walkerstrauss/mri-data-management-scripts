#!/bin/bash -l
echo "************************************TOP OF PROGRAM****************************************"

# Set the path to your pulled DICOM directories
home=/path/to/your/study/dicom_data/
module load dcm2niix  # Only needed if running in an environment like a cluster

# Automatically list participants (assumes each participant has a folder)
individuals=$(ls -d "${home}"*/)

echo "Found participants:"
echo "$individuals"

echo "************************************START LOOP****************************************"

for participant in $individuals; do
    echo
    echo "*** Participant ***"
    echo "$participant"
    echo "*******************"

    cd "$participant" || { echo "Could not access $participant"; continue; }

    # List all scan folders (typically organized by series)
    folders=$(ls -d */)

    echo "Found scan folders:"
    echo "$folders"

    for scan in $folders; do
        scan_path="${participant}${scan}"
        echo "--- Scan Directory ---"
        echo "$scan_path"

        # Report the size of each scan folder
        du -sh "$scan_path"
        echo "----------------------"

        # Optional: run dcm2niix here if converting
        # dcm2niix -o /your/output/path -f "%p_%s" "$scan_path"
    done
done

echo
echo "************************************END OF PROGRAM****************************************"
