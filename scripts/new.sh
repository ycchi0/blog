#!/bin/bash

# 提示用户输入文章名，如果为空则退出脚本
echo "Please enter the article name (leave blank to exit):"
read a

if [ -z "$a" ]; then
  echo "No article name entered, exiting script."
  exit 0
fi

echo "Creating new post with the name: $a"
hugo new content posts/$a/index.md

