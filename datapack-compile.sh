#!/usr/bin/env bash

mkdir -p ./datapack/data/computercraft/lua/rom/
mkdir ./out
cp bios.lua datapack/data/computercraft/lua/bios.lua
cp -r ./bin datapack/data/computercraft/lua/rom/bin
cp -r ./apis datapack/data/computercraft/lua/rom/apis
cp -r ./boot datapack/data/computercraft/lua/rom/boot
cp -r ./enums datapack/data/computercraft/lua/rom/enums

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
