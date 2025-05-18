FROM codercom/code-server

# cource: https://github.com/coder/code-server/blob/main/ci/release-image/Dockerfile

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sudo sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

RUN sudo apt update && \
    sudo apt install -y build-essential && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

RUN code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans@1.99.0 && \
    code-server --install-extension RooVeterinaryInc.roo-cline

COPY . /home/coder/.local/share/code-server/

RUN echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/brew.git"' >> ~/.brewrc && \
    echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"' >> ~/.brewrc && \
    echo 'export HOMEBREW_API_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles/api"' >> ~/.brewrc && \
    echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"' >> ~/.brewrc && \
    echo >> ~/.bashrc && echo '. ~/.brewrc' >> ~/.bashrc && \
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://fastly.jsdelivr.net/gh/Homebrew/install/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.brewrc

WORKDIR /WORKSPACE

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "."]
