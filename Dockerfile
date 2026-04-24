FROM linuxserver/code-server

# cource: https://github.com/linuxserver/docker-code-server/blob/master/Dockerfile

RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sudo sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

RUN apt update && \
    apt install -y build-essential jq && \
    apt autoremove -y && apt autoclean && apt-get clean && rm -rf /var/lib/apt/lists/*


##################################### bashrc ##########################################


COPY .bashrc.d /tmp/.bashrc.d

RUN mv /tmp/.bashrc.d $HOME/.bashrc.d && \
    cp /etc/skel/.bashrc $HOME/.bashrc && \
    echo '. ~/.bashrc.d/.bashrc' >> $HOME/.bashrc
    
RUN curl https://chsrc.run/posix | bash

##################################### code-server #####################################

COPY code-server /tmp/code-server

RUN mv /tmp/code-server $HOME/data

RUN export PATH=/app/code-server/bin:$PATH && \
    code-server --user-data-dir /config/data --extensions-dir /config/extensions --install-extension MS-CEINTL.vscode-language-pack-zh-hans && \
    code-server --user-data-dir /config/data --extensions-dir /config/extensions --install-extension kilocode.kilo-code && \
    . $HOME/data/languagepacks.sh


########################################### zerobrew ###########################################

RUN curl -fsSL https://zerobrew.rs/install | sed 's/github\.com/g.stevie.top\/github.com/g' | sed 's/$EUID -eq 0/$EUID -eq 1/g' | bash

############################################ mise ##############################################

RUN curl https://mise.run | sh && \
    echo 'eval "$(mise activate bash --shims)"' >> ~/.bashrc.d/00-mise.bashrc

RUN echo 'abc:abc' | chpasswd && \
    echo 'root:root' | chpasswd && \
    echo 'abc ALL=(ALL) ALL' >> /etc/sudoers

##################################### starship #####################################

RUN zb install starship && \
    mkdir -p ~/.config && echo "'$schema' = 'https://starship.rs/config-schema.json'" >> ~/.config/starship.toml && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc.d/00-starship.bashrc


EXPOSE 8443
