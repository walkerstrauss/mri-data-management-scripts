#!/bin/bash -l
echo "************************************TOP OF PROGRAM****************************************"

home=# path to pulled MRI data
dest=# path to data destination
mkdir -p "$dest"

# Map participants to anonymized experimental conditions
# Example: HUMAN_HD-001="YOUR_SESSION_1", HUMAN_HD-001_2="YOUR_SESSION_2"
declare -A shape_map=(
   # HUMAN_HD-001="YOUR_SESSION_1"
   # HUMAN_HD-001_2="YOUR_SESSION_2"
   # ...
)

echo "************************************START LOOP****************************************"

for folder in "$home"/HUMAN_HD-*; do
  [ -d "$folder" ] || continue
  participant=$(basename "$folder")

  shape=${shape_map[$participant]}
  if [[ -z "$shape" ]]; then
    echo "Skipping $participant — no shape mapped"
    continue
  fi

  # Determine session label from shape
  if [[ "$shape" == "YOUR_SESSION_1" ]]; then
    session="g1"
  elif [[ "$shape" == "YOUR_SESSION_2" ]]; then
    session="g2"
  else
    echo "Unknown shape for $participant: $shape"
    continue
  fi

  # Normalize ID for participants with two sessions
  base_id=$(echo "$participant" | sed 's/_2$//')
  dest_folder="${dest}/${base_id}"
  mkdir -p "$dest_folder"

  echo "*** Copying $participant as $session → $dest_folder"

  for file in "$folder"/*.{nii,json}; do
    [ -f "$file" ] || continue
    name=$(basename "$file")
    stem="${name%.*}"
    ext="${name##*.}"
    newname="${stem}_${session}.${ext}"
    cp -u "$file" "${dest_folder}/${newname}"
    echo "  Copied $name → $newname"
  done
done
