#!/bin/bash

# Path to your organized MRI data folder (replace with your actual path when using)
dest=/path/to/final/MRI_data

# List of file base names to keep (without session suffixes) -> replace with your actual scans when using
keep_list=(
  MPRAGE
  DWI
  Run_1
  Run_2
  Run_3
  Run_4
  Run_5
  Run_6
  Resting_State
  Localizer
  sag_T2_FSE
  TSE
)

echo "Cleaning and renaming .nii files..."

# Loop through all participant folders (assumed naming: STUDY_ID-###)
for subj in "$dest"/STUDY_ID-*; do
  [ -d "$subj" ] || continue
  echo "Processing $subj"

  for file in "$subj"/*.nii; do
    [ -f "$file" ] || continue
    fname=$(basename "$file")

    keep=false
    for base in "${keep_list[@]}"; do
      if [[ "$fname" == "${base}_s1.nii" || "$fname" == "${base}_s2.nii" ]]; then
        keep=true
        break
      fi
    done

    if ! $keep; then
      echo "Deleting: $file"
      rm "$file"
    else
      # Rename _s1 → _g1 and _s2 → _g2 to anonymize session condition
      if [[ "$file" == *_s1.nii ]]; then
        newname="${file/_s1.nii/_g1.nii}"
        mv "$file" "$newname"
        echo "Renamed $file → $newname"
      elif [[ "$file" == *_s2.nii ]]; then
        newname="${file/_s2.nii/_g2.nii}"
        mv "$file" "$newname"
        echo "Renamed $file → $newname"
      fi
    fi
  done
done

echo "Done."
