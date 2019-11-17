#!/usr/bin/env bash
set -e

# Usage function
usage () {

  # show usage information
  echo ""
  echo "Usage: create_qcow_image.sh <image.yaml>"
  echo ""

  # display potential error message
  if [ "$#" -eq 1 ]; then
      echo "  $1"
      echo ""
  fi

  # abort the script
  exit 1
}

# Check if parameter has been provided
if [ "$#" -ne 1 ]; then
    usage "Missing parameter"
fi

# Check if first parameter is an existing file
if [ ! -f $1 ]; then
    usage "Can not find yaml-file"
fi

# Check if enough disk space is available
export gigabytes_available=`df -g . | sed '1d' | tr -s ' ' | cut -d ' ' -f 4`
if (($gigabytes_available < 8)); then
    echo "Not enough disk space available: $gigabytes_available GB"
    exit 1
fi

# ------------------------------------------------------------------------------

# 0. Change current directory to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# 1. Cleanup work directory
rm -rf "./work/*" 2>&1 > /dev/null

# 2. Create a small script to convert yaml into environment variables => image.sh
cat $1 | python -c "$(cat <<_EOF_
import sys, yaml;
data = "";
for line in sys.stdin:
    data = data + line;

variables = yaml.safe_load(data);

for var in variables:
    if '\n' in variables[var]:
      print( "export " + var + "='\n" + str(variables[var])  + "'")
    else:
      print( "export " + var + "=\"" + str(variables[var])  + "\"")

print( "set -x" )
print( "disk-image-create \$ELEMENTS \$PARAMETERS" )
_EOF_
)" > work/image.sh

# 3. Remove the diskimage_builder container
docker kill diskimage_builder 2>&1 > /dev/null || true
docker rm   diskimage_builder 2>&1 > /dev/null || true

# 4. Start the diskimage-builder container
docker run -itd --rm --privileged --name diskimage_builder tsai/diskimage-builder

# 5. Copy any project resources into the container
if [ -d ./custom ]
then
  docker cp ./custom diskimage_builder:/opt/builder/
fi

# 6. Execute diskimage-create command
docker exec -i diskimage_builder /bin/bash < work/image.sh | tee work/image.log

# 7. Copy the created image to the local filesystem
docker cp diskimage_builder:/opt/builder/image.qcow2 work

# 8. Remove the diskimage_builder container
docker kill diskimage_builder 2>&1 > /dev/null || true
