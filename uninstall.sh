#!/bin/bash

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

echo "OK"
