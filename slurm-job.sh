#!/bin/bash

#SBATCH --job-name=SE4HPC-project ## Name of the job
#SBATCH --output=slurmout.txt     ## Stdout
#SBATCH --error=slurmerr.txt      ## Stderr
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00              ## Job Duration

export TMPDIR=$HOME/tmp
mkdir -p $TMPDIR

OUT_ZIP_FILE="image.zip"

# Fetch the latest artifacts JSON
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/mattteochen/SE4HPC_project_2_ChenPisante/actions/artifacts \
  -o artifacts.json

# Extract the download URL of the latest artifact
LATEST_URL=$(python3 artifacts_link.py)

echo  "Latest artifact download URL: $LATEST_URL"

# Download the latest artifact
if [ -n "$LATEST_URL" ]; then
  curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -o "$OUT_ZIP_FILE" \
  "$LATEST_URL"
  echo "Downloaded latest artifact to $OUT_ZIP_FILE"
  # Unzip artifact
  unzip -o "$OUT_ZIP_FILE"
  # Run image
  srun singularity exec --bind $TMPDIR:/scratch_local TestMultiplication.sif bash -c "mpirun -np 2 /opt/build_files/build/main"
else
  echo "No artifact found."
fi
