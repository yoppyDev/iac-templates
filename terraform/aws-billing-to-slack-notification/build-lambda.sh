#!/bin/bash
# 参考にした記事 ： https://dev.classmethod.jp/articles/terraform-lambda-deployment/

if [ -d build ]; then
  rm -rf build
fi

# Recreate build directory
mkdir -p build/function/ build/layer/

# Copy source files
echo "Copy source files"
cp -r lambda build/function/

# Pack python libraries
echo "Pack python libraries"
pip3 install -r lambda/requirements.txt -t build/layer/python

# Remove pycache in build directory
find build -type f | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm