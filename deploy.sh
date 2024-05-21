#!/bin/bash

# 定义目标文件夹路径
TARGET_DIR="../ycchi0.github.io"

# 创建目标文件夹，如果不存在的话
mkdir -p "$TARGET_DIR"

# 进入你的Hugo项目目录，这里需要替换为你的实际项目路径

# 使用Hugo生成静态网页到public目录
hugo

# 确保public目录存在
if [ -d "public" ]; then
    # 复制public目录下的内容到目标文件夹
    cp -R public/* "$TARGET_DIR"

    cd $TARGET_DIR
    # 添加所有更改到Git暂存区
    git add .

    # 提交更改
    git commit -m "Deploy"

    # 推送到远程仓库的main分支
    echo $REMOTE_NAME $BRANCH_NAME
    git push "$REMOTE_NAME" "$BRANCH_NAME"

else
    echo "Error: 'public' directory does not exist."
    exit 1
fi




echo "Deployment completed successfully."