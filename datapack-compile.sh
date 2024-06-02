#!/usr/bin/env bash

mkdir -p ./datapack/data/computercraft/lua/rom/
mkdir ./out
cp bios.lua datapack/data/computercraft/lua/bios.lua
cp -r ./bin datapack/data/computercraft/lua/rom/bin
cp -r ./apis datapack/data/computercraft/lua/rom/apis
cp -r ./boot datapack/data/computercraft/lua/rom/boot
cp -r ./enums datapack/data/computercraft/lua/rom/enums

echo '{' > datapack/pack.mcmeta
echo '  "pack": {' >> datapack/pack.mcmeta
echo '    "pack_format": 18,' >> datapack/pack.mcmeta
echo '    "description": "GoofballOS datapack for CC: Tweaked"' >> datapack/pack.mcmeta
echo '  }' >> datapack/pack.mcmeta
echo '}' >> datapack/pack.mcmeta

cd datapack

zip -r ../out/goofballos-datapack.zip ./*
