VERIFY_TEMP_DIR="$TMPDIR/.vunzip"
mkdir "$VERIFY_TEMP_DIR"

abort_verify() {
      ui_print "----------------------------------------------"
      echo "Error: File integrity compromised.⚠️"
      echo "Please download the module again"
      echo "from its official source to restore it."
      sleep 2
      abort "----------------------------------------------"
}

# Extracts a file from a zip archive.
# Usage: extract <zip_file> <file_path> <target_dir> [<junk_paths>]
extract() {
  local zip_file="$1"
  local file_path="$2"
  local target_dir="$3"
  local junk_paths="${4:-false}"
  local unzip_options="-o"
  local extracted_file

  # Determine if we are ignoring directory structure in the archive
  if [ "$junk_paths" = true ]; then
    unzip_options="-oj"
    extracted_file="$target_dir/$(basename "$file_path")"
  else
    extracted_file="$target_dir/$file_path"
  fi

  # Extract the file
  unzip $unzip_options "$zip_file" "$file_path" -d "$target_dir" >&2
  [ -f "$extracted_file" ] || abort_verify "$file_path not found after extraction"

  ui_print "- Extracted $file_path" >&1
}

# Main verification for update-binary
local update_binary="META-INF/com/google/android/update-binary"
# Extract META-INF files
unzip -o "$ZIPFILE" "META-INF/com/google/android/*" -d "$VERIFY_TEMP_DIR" >&2
extract "$ZIPFILE" "$update_binary" "$VERIFY_TEMP_DIR" # Verify update binary

# List of files to extract (excluding directories)
extract "$ZIPFILE" "verify.sh" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "customize.sh" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "service.sh" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "system.prop" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "post-fs-data.sh" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "README.md" "$VERIFY_TEMP_DIR"
extract "$ZIPFILE" "uninstall.sh" "$VERIFY_TEMP_DIR"