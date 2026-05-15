FROM ghcr.io/coder/code-server

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sudo sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

##################################### bashrc ##########################################

COPY .bashrc.d /tmp/.bashrc.d

RUN echo $HOME

RUN mv /tmp/.bashrc.d $HOME/.bashrc.d && \
    cp /etc/skel/.bashrc $HOME/.bashrc && \
    echo '. ~/.bashrc.d/.bashrc' >> $HOME/.bashrc

    ##################################### code-server #####################################

COPY code-server /tmp/code-server

RUN mv /tmp/code-server $HOME/data

RUN export PATH=/app/code-server/bin:$PATH && \
    code-server --user-data-dir /config/data --extensions-dir /config/extensions --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    . $HOME/.local/share/code-server/languagepacks-coder.sh


WORKDIR /workspace

CMD --auth=none
