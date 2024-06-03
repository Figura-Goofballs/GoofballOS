#!/usr/bin/env bash

mkdir -p ./datapack/data/computercraft/lua/rom/
mkdir ./datapack/data/computercraft/lua/rom/bin
mkdir ./datapack/data/computercraft/lua/rom/apis
mkdir ./datapack/data/computercraft/lua/rom/boot
mkdir ./datapack/data/computercraft/lua/rom/enums
mkdir ./out

luamin -f bios.lua > ./datapack/data/computercraft/lua/bios.lua
find bin apis boot enums -type f -exec sh -c "luamin -f {} > ./datapack/data/computercraft/lua/rom/{}" \;

cd datapack
cat > pack.mcmeta <<json
{
  "pack": {
    "pack_format": 18,
    "description": "GoofballOS datapack for CC: Tweaked"
  }
}
json

zip -r ../out/goofballos-datapack.zip ./*
