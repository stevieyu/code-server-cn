export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"
export HOMEBREW_API_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"

command -v zb >/dev/null 2>&1 && eval "$(zb completion bash)"

#export PATH=$HOME/.local/share/zerobrew/prefix/opt/rustup/bin:$PATH
#export PATH=$HOME/.local/share/zerobrew/prefix/Cellar/node/25.8.2/bin:$PATH
