FROM docker.1panel.live/nixos/nix

# 配置国内 binary cache 镜像, 替换 channel 为国内源
RUN mkdir -p /root/.config/nix && \
    echo 'substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/' > /root/.config/nix/nix.conf && \
    nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable nixpkgs && \
    nix-channel --update

# ============================================================
# 安装相关环境
# ============================================================
# 安装所需软件
RUN nix-env -iA \
    nixpkgs.openssh \
    nixpkgs.curl \
    nixpkgs.tini \
    nixpkgs.bash

# 创建用户数据库：root 空密码，shell 为 /bin/sh；sshd 用于权限分离
# shadow 中 root 的 lastchange 设为 19999（避免“密码过期”误判）
RUN echo 'root:x:0:0:root:/root:/bin/sh' > /etc/passwd \
    && echo 'sshd:x:22:22:Privilege-separated SSH:/var/empty:/sbin/nologin' >> /etc/passwd \
    && echo 'root::19999:0:99999:7:::'           > /etc/shadow \
    && echo 'sshd:!!:19000:0:99999:7:::'         >> /etc/shadow \
    && echo 'root:x:0:'                          > /etc/group \
    && echo 'sshd:x:22:'                         >> /etc/group \
    && chmod 644 /etc/passwd /etc/group \
    && chmod 600 /etc/shadow

# 创建必要目录、主机密钥、sshd 配置，并创建 lastlog 文件
RUN mkdir -p /var/empty /var/run/sshd /etc/ssh /var/log \
    && chmod 755 /var/empty \
    && ssh-keygen -A \
    && touch /var/log/lastlog \
    && printf '%s\n' \
        'Port 22' \
        'PermitRootLogin yes' \
        'PermitEmptyPasswords yes' \
        'PasswordAuthentication yes' \
        'UsePAM no' \
        'ChallengeResponseAuthentication no' \
        'X11Forwarding no' \
        'PrintLastLog yes' \
        'Subsystem sftp internal-sftp' \
        > /etc/ssh/sshd_config

# 将 Nix 安装的程序加入 PATH（方便手动调试）
ENV PATH="/root/.nix-profile/bin:/root/.nix-profile/sbin:${PATH}"

# nix-env --install --attr devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable

EXPOSE 22

ENTRYPOINT ["tini", "--"]
# 启动前创建 /run 目录，再以绝对路径启动 sshd
CMD ["sh", "-c", "mkdir -p /run && exec /root/.nix-profile/bin/sshd -D -e"]

# wslc build -t devenv:ssh -f devenv.Dockerfile .
# wslc run --rm -it -p 8022:22 -p 8080:8080 -v ${HOME}/.ssh:/root/.ssh devenv:ssh
