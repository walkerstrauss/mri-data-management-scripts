#!/bin/bash -l

echo "************************************TOP OF PROGRAM****************************************"

# Set source directory for DICOM data
home=/path/to/dicom_data
module load dcm2niix

# Generate subject list (example: SUBJECT_001 to SUBJECT_045 and their second sessions)
individuals=""
for i in $(seq -w 1 45); do
  individuals+="SUBJECT_${i} SUBJECT_${i}_2 "
done

echo "Subjects: $individuals"
echo "************************************START LOOP****************************************"

for participant in $individuals; do
  cd "$home" || exit
  cd "$participant" || continue
  echo "*** Processing Participant: $participant ***"

  folders=$(ls -d */)
  for scan in $folders; do
    echo "*** Scan: $scan ***"
    number=${scan::-1}

    non_dcm_files=$(ls "${scan}" | grep -v "dcm" | wc -l)
    first_dcm_file=$(ls "${scan}" | grep "dcm" | head -n 1)

    # Run conversion if no .nii or .json exists
    if [[ $non_dcm_files -lt 3 ]]; then
      echo "Running dcm2niix for conversion..."
      dcm2niix "$scan"
    fi

    # Create scan info text if it doesn't already exist
    if [[ -f ${scan}/scan_${number} ]]; then
      echo "Scan info file exists."
    else
      echo "Generating scan info file..."
      dicom_hdr "${scan}${first_dcm_file}" > "${scan}/scan_${number}"
    fi

    # Parse series description from first .json file
    json_file=$(ls "${scan}"/*.json | head -n 1)
    if [[ -f "$json_file" ]]; then
      series_description=$(grep -i '"SeriesDescription"' "$json_file" | sed -E 's/.*: "(.*)",?/\1/' | tr '[:upper:]' '[:lower:]')
    else
      echo "No .json file found in $scan — skipping renaming."
      continue
    fi

    # Example renaming based on general scan types — adjust to your anonymized descriptions
    if [[ "$series_description" == *"t1-weighted"* ]]; then
      mv "${scan}"/*.nii "${scan}/T1.nii"
      echo "Renamed T1-weighted anatomical scan"
    fi

    if [[ "$series_description" == *"functional run 1"* ]]; then
      mv "${scan}"/*.nii "${scan}/task_run1.nii"
      echo "Renamed Functional Run 1"
    fi

    if [[ "$series_description" == *"multi-echo run 1"* ]]; then
      mv "${scan}"/*e1.nii "${scan}/task_run1_e1.nii"
      mv "${scan}"/*e2.nii "${scan}/task_run1_e2.nii"
      mv "${scan}"/*e3.nii "${scan}/task_run1_e3.nii"
      echo "Renamed Multi-Echo Run 1"
    fi

    if [[ "$series_description" == *"functional run 2"* ]]; then
      mv "${scan}"/*.nii "${scan}/task_run2.nii"
      echo "Renamed Functional Run 2"
    fi

    if [[ "$series_description" == *"multi-echo run 2"* ]]; then
      mv "${scan}"/*e1.nii "${scan}/task_run2_e1.nii"
      mv "${scan}"/*e2.nii "${scan}/task_run2_e2.nii"
      mv "${scan}"/*e3.nii "${scan}/task_run2_e3.nii"
      echo "Renamed Multi-Echo Run 2"
    fi

    if [[ "$series_description" == *"diffusion-weighted"* ]]; then
      mv "${scan}"/*.nii "${scan}/DTI.nii"
      echo "Renamed Diffusion-Weighted Scan"
    fi

    if [[ "$series_description" == *"experimental task"* ]]; then
      mv "${scan}"/*.nii "${scan}/task_experimental.nii"
      echo "Renamed Experimental Task"
    fi

    if [[ "$series_description" == *"multi-echo experimental"* ]]; then
      mv "${scan}"/*e1.nii "${scan}/task_experimental_e1.nii"
      mv "${scan}"/*e2.nii "${scan}/task_experimental_e2.nii"
      mv "${scan}"/*e3.nii "${scan}/task_experimental_e3.nii"
      echo "Renamed Multi-Echo Experimental Task"
    fi

  done
done
