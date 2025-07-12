#!/bin/bash

# source: https://www.anye.xyz/archives/A2n9F5qa

# 定义路径
EXTENSIONS_DIR="$HOME/.local/share/code-server/extensions"
OUTPUT_DIR="$HOME/.local/share/code-server"
LANGUAGE_PACK_PREFIX="ms-ceintl.vscode-language-pack-"

# 定义输出文件
LANGUAGEPACKS_FILE="$OUTPUT_DIR/languagepacks.json"
ARGV_FILE="$OUTPUT_DIR/User/argv.json"
EXTENSIONS_JSON="$EXTENSIONS_DIR/extensions.json"

# 创建 User 目录（如果不存在）
mkdir -p "$(dirname "$ARGV_FILE")"

# 查找语言包目录
LANGUAGE_PACK_FOLDER=$(find "$EXTENSIONS_DIR" -type d -name "${LANGUAGE_PACK_PREFIX}*" | head -n 1)

# 检查语言包文件夹是否存在
if [ -z "$LANGUAGE_PACK_FOLDER" ]; then
  echo "未找到语言包文件夹，请确保路径正确。"
  exit 1
fi

# 从 package.json 中提取数据
PACKAGE_JSON="$LANGUAGE_PACK_FOLDER/package.json"
if [ ! -f "$PACKAGE_JSON" ]; then
  echo "未找到 package.json 文件，请检查语言包目录。"
  exit 1
fi

# 从 extensions.json 中提取 UUID
if [ ! -f "$EXTENSIONS_JSON" ]; then
  echo "未找到 extensions.json 文件，请检查路径。"
  exit 1
fi

LANGUAGE_PACK_NAME=$(jq -r '.name' "$PACKAGE_JSON")
echo "找到语言包: $LANGUAGE_PACK_NAME"
LANGUAGE_PACK_UUID=$(jq -r --arg id "ms-ceintl.$LANGUAGE_PACK_NAME" '.[] | select(.identifier.id == $id) | .identifier.uuid' "$EXTENSIONS_JSON")

if [ -z "$LANGUAGE_PACK_UUID" ]; then
  echo "未能在 extensions.json 中找到对应语言包的 UUID"
  exit 1
fi

# 提取其他必要信息
LANGUAGE_ID=$(jq -r '.contributes.localizations[0].languageId' "$PACKAGE_JSON")
LANGUAGE_LABEL=$(jq -r '.contributes.localizations[0].localizedLanguageName' "$PACKAGE_JSON")
LANGUAGE_PACK_VERSION=$(jq -r '.version' "$PACKAGE_JSON")

# 动态生成 translations
TRANSLATIONS=$(jq -n --arg dir "$LANGUAGE_PACK_FOLDER" --argjson translations "$(jq '.contributes.localizations[0].translations' "$PACKAGE_JSON")" '
  reduce $translations[] as $item ({}; . + {($item.id): "\($dir)/\($item.path)"})
')

# 生成 languagepacks.json
HASH=$(echo -n "$LANGUAGE_PACK_UUID$LANGUAGE_PACK_VERSION" | md5sum | awk '{print $1}')
cat > "$LANGUAGEPACKS_FILE" <<EOL
{
    "${LANGUAGE_ID}": {
        "hash": "${HASH}",
        "extensions": [
            {
                "extensionIdentifier": {
                    "id": "${LANGUAGE_PACK_NAME}",
                    "uuid": "${LANGUAGE_PACK_UUID}"
                },
                "version": "${LANGUAGE_PACK_VERSION}"
            }
        ],
        "translations": ${TRANSLATIONS},
        "label": "${LANGUAGE_LABEL}"
    }
}
EOL

# 格式化 languagepacks.json
jq '.' "$LANGUAGEPACKS_FILE" > "$LANGUAGEPACKS_FILE.tmp" && mv "$LANGUAGEPACKS_FILE.tmp" "$LANGUAGEPACKS_FILE"
echo "languagepacks.json 已生成并格式化: $LANGUAGEPACKS_FILE"

# 生成 argv.json
cat > "$ARGV_FILE" <<EOL
{
    "locale": "${LANGUAGE_ID}"
}
EOL

# 格式化 argv.json
jq '.' "$ARGV_FILE" > "$ARGV_FILE.tmp" && mv "$ARGV_FILE.tmp" "$ARGV_FILE"
echo "argv.json 已生成并格式化: $ARGV_FILE"