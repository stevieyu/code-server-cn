FROM ghcr.io/coder/code-server

USER root

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

RUN apt update && \
    apt install -y --no-install-recommends jq && \
    apt autoremove -y && apt autoclean && apt-get clean && rm -rf /var/lib/apt/lists/*

USER coder
##################################### bashrc ##########################################

COPY .bashrc.d /home/coder/.bashrc.d
RUN sudo chown -R coder:coder $HOME/.bashrc.d

RUN cp /etc/skel/.bashrc $HOME/.bashrc && \
    echo '. ~/.bashrc.d/.bashrc' >> $HOME/.bashrc

##################################### code-server #####################################

COPY code-server /home/coder/.local/share/code-server
RUN sudo chown -R coder:coder $HOME/.local

RUN code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    . $HOME/.local/share/code-server/languagepacks-coder.sh


# WORKDIR /workspace

CMD ["--auth=none"]


# podman run --rm -it -p 8080:8080 ccs
