#!/bin/bash

url=${1:?'Package url is required!'}
filename=$(basename "$url")
basename=${filename%.*}
version=${basename##*-}
version_pattern='*.*.*.*'
if [[ "$version" != $version_pattern ]]; then
  echo "Package version is not found in \"$url\"!"
  exit 1
fi

# It's really weird that /var/lib/waagent can'te be a install_path: files
# downloaded by curl to it are just gone, while curl exits OK!
install_path=${install_path:-~}
if [[ ! -d "$install_path" ]]; then
  echo "Dir \"$install_path\" doesn't exist!"
  exit 1
fi

echo "Enter \"$install_path\""
cd "$install_path" || exit 1

name_prefix='Microsoft.HpcPack.HpcAcmAgent-'
for f in "$name_prefix"*; do
  if [[ -d "$f" ]]; then
    cd "$f"
    echo "Disable and uninstall \"$f\"..."
    if python hpcacmagent.py -disable && python hpcacmagent.py -uninstall ; then
      echo "OK"
    else
      echo "Warning: disable/uninstall \"$f\" failed!"
    fi
    cd ..
  fi
done

echo "Downloading \"$url\" to \"$filename\"..."
curl -L -o "$filename" "$url" || exit 1

dir="$name_prefix$version"
echo "Unzipping \"$filename\" to \"$dir\"..."
unzip -o -d "$dir" "$filename" || exit 1

echo "Preparing to run..."
cd "$dir" || exit 1
mkdir config log status
touch config/0.settings
chmod +x hpcacmagent.py

path="$install_path/$dir"
echo "
[
    {
        \"handlerEnvironment\": {
            \"configFolder\": \"$path/config\",
            \"heartbeatFile\": \"$path/log/heartbeat.log\",
            \"logFolder\": \"$path/log\",
            \"statusFolder\": \"$path/status\"
        },
        \"name\": \"Microsoft.HpcPack.HpcAcmAgent.Dev\",
        \"version\": 1.0
    }
]
" > HandlerEnvironment.json


echo "Starting..."
python hpcacmagent.py -install && python hpcacmagent.py -enable
code=$?
echo "Return code: $code"
exit $code
