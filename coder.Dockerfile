FROM ghcr.io/coder/code-server

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sudo sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

##################################### bashrc ##########################################

COPY .bashrc.d /tmp/.bashrc.d

RUN mv /tmp/.bashrc.d $HOME/.bashrc.d && \
    cp /etc/skel/.bashrc $HOME/.bashrc && \
    echo '. ~/.bashrc.d/.bashrc' >> $HOME/.bashrc


WORKDIR /workspace

CMD --auth=none
