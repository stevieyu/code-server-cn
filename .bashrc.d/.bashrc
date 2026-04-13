# 批量添加路径到 PATH 变量
# 防止重复添加已存在的路径
PATHS_TO_ADD=(
  "$HOME/.local/bin"
  "$HOME/.local/share/zerobrew/prefix/bin"
)
for path in "${PATHS_TO_ADD[@]}"; do
  [[ ":$PATH:" != *":$path:"* ]] && export PATH="$path:$PATH"
done


# 遍历 .bashrc.d 目录下的配置文件并加载
# 文件命名格式：[0-9][0-9]-*.bashrc（数字前缀用于控制加载顺序）
for i in "${HOME}/.bashrc.d"/[0-9][0-9]-*.bashrc; do
  if [ -r "$i" ]; then
    . "$i"
  fi
done
# 清理循环变量，防止污染环境
unset i


