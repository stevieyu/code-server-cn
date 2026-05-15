FROM ghcr.io/coder/code-server

USER root

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

RUN apt update && \
    apt install -y --no-install-recommends jq libatomic1 && \
    apt autoremove -y && apt autoclean && apt-get clean && rm -rf /var/lib/apt/lists/*

USER coder
##################################### bashrc ##########################################

COPY --chown=coder:coder .bashrc.d /home/coder/.bashrc.d

RUN cp /etc/skel/.bashrc $HOME/.bashrc && \
    echo '. ~/.bashrc.d/.bashrc' >> $HOME/.bashrc

########################################### zerobrew ###########################################

RUN curl -fsSL https://zerobrew.rs/install | sed 's|github.com|gh.g.stevie.top/github.com|g' | sed 's/$EUID -eq 0/$EUID -eq 1/g' | bash


############################################ mise ##############################################

RUN curl https://mise.run | sh && \
    echo 'eval "$(mise activate bash --shims)"' >> ~/.bashrc.d/00-mise.bashrc


##################################### starship #####################################

RUN curl -sS https://starship.rs/install.sh | sed 's|github.com|gh.g.stevie.top/github.com|g' | sh -s -- -y && \
    mkdir -p ~/.config && echo "\"\$schema\" = 'https://starship.rs/config-schema.json'" >> ~/.config/starship.toml && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc.d/00-starship.bashrc


##################################### code-server #####################################

COPY --chown=coder:coder code-server /home/coder/.local/share/code-server

RUN code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    . $HOME/.local/share/code-server/languagepacks-coder.sh

COPY --chown=coder:coder mcp_settings.json /home/coder/.local/share/code-server/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json
RUN code-server --install-extension kilocode.kilo-code


WORKDIR /workspace

CMD ["--auth=none"]


# podman run --rm -it -p 8080:8080 ccs
