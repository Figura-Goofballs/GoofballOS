#!/usr/bin/env bash

mkdir -p ./datapack/data/computercraft/lua/rom/
mkdir ./datapack/data/computercraft/lua/rom/bin
mkdir ./datapack/data/computercraft/lua/rom/apis
mkdir ./datapack/data/computercraft/lua/rom/boot
mkdir ./datapack/data/computercraft/lua/rom/enums
mkdir ./out

luamin -f bios.lua > ./datapack/data/computercraft/lua/bios.lua
find ./bin/* -exec sh -c "luamin -f {} > ./datapack/data/computercraft/lua/rom/{}" \;
find ./apis/* -exec sh -c "luamin -f {} > ./datapack/data/computercraft/lua/rom/{}" \;
find ./boot/* -exec sh -c "luamin -f {} > ./datapack/data/computercraft/lua/rom/{}" \;
find ./enums/* -exec sh -c "luamin -f {} > ./datapack/data/computercraft/lua/rom/{}" \;

echo '{' > datapack/pack.mcmeta
echo '  "pack": {' >> datapack/pack.mcmeta
echo '    "pack_format": 18,' >> datapack/pack.mcmeta
echo '    "description": "GoofballOS datapack for CC: Tweaked"' >> datapack/pack.mcmeta
echo '  }' >> datapack/pack.mcmeta
echo '}' >> datapack/pack.mcmeta

cd datapack

zip -r ../out/goofballos-datapack.zip ./*
