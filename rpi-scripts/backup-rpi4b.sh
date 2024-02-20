#!/usr/bin/bash

# Default values for in and out files
in_file="/dev/mmcblk0"
out_file="/mnt/rpi4b-backups-bk/rpi4b-backups-backup.img"

# Parse command-line options
while getopts ":i:o:" opt; do
  case $opt in
    i)
      in_file="$OPTARG"
      ;;
    o)
      out_file="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Create log file
# Base path
log_path="/home/ivar/backup_logs"

# Get the script name without the path or the .sh
script_name=$(basename "$0" .sh)

# Generate timestamp in the format YYYY-MM-DD-HH-MM-SS
timestamp=$(date +"%Y-%m-%d-%H-%M-%S")

# Construct the log file name
log_file="${log_path}/${script_name}-${timestamp}.log"

echo "############################################################################" >> "$log_file"
echo "# rpi backup log created $timestamp." >> "$log_file"
echo "############################################################################" >> "$log_file"

# Perform the backup
# Use pv to show progress
output=$(pv "$in_file" | dd  of="$out_file" bs=4M status=progress 2>&1)
copy_exit_status=$?

echo "$output" >> "$log_file"

if [ $copy_exit_status -eq 0 ]; then
    echo "Backup of $in_file to $out_file has completed successfully." >> "$log_file"
    exit 0
else
    echo "Backup of $in_file to $out_file was unsuccessful." >> "$log_file"
   exit 2
fi
