FROM codercom/code-server

# cource: https://github.com/coder/code-server/blob/main/ci/release-image/Dockerfile

USER root

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sudo sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

RUN apt update && \
    apt install -y build-essential jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


######################################################################################

USER coder

RUN code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    code-server --install-extension kilocode.kilo-code

COPY . /home/coder/.local/share/code-server/

RUN sudo chown -R $USER:$USER ~/.local/share/code-server/User && \
    . ~/.local/share/code-server/languagepacks.sh && \
    echo >> ~/.bashrc && echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc 

# RUN echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/brew.git"' >> ~/.brewrc && \
#     echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"' >> ~/.brewrc && \
#     echo 'export HOMEBREW_API_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles/api"' >> ~/.brewrc && \
#     echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"' >> ~/.brewrc && \
#     echo >> ~/.bashrc && echo '. ~/.brewrc' >> ~/.bashrc && \
#     NONINTERACTIVE=1 bash -c "$(curl -fsSL https://fastly.jsdelivr.net/gh/Homebrew/install/install.sh)" && \
#     echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.brewrc

# RUN curl https://mise.run | sh && \
#     echo >> ~/.bashrc && echo 'eval "$(mise activate bash --shims)"' >> ~/.bashrc

# RUN sudo install -dm 755 /etc/apt/keyrings && \
#     wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null && \
#     echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list && \
#     sudo apt update && sudo apt install -y mise

RUN curl https://mise.run | sh

WORKDIR /WORKSPACE

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "."]
