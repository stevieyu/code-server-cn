FROM docker.1panel.live/library/node:lts-slim

# ============================================================
# 配置 Debian apt 国内镜像源，这里使用阿里云
# 阿里源：mirrors.aliyun.com
# 清华源：mirrors.tuna.tsinghua.edu.cn
# ============================================================
RUN find /etc -regex '.*\(repositories\|sources.list\(.d\/.*\)?\)$' | xargs sed -i -E 's/(archive|security).ubuntu.com|(deb).debian.org|dl-cdn.alpinelinux.org/mirrors.aliyun.com/g'

# ============================================================
# 配置 npm 国内镜像源
# ============================================================
RUN npm config set registry https://registry.npmmirror.com

# ============================================================
# 安装相关环境
# ============================================================
RUN apt-get update && apt-get install -y \
        tini \
        openssh-server \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# 创建 sshd 运行目录并生成主机密钥
#
# 清空 root 密码，实现无密码登录
#
# 允许 root 登录
# 允许密码登录
# 允许空密码登录
# ============================================================
RUN mkdir -p /run/sshd \
    && ssh-keygen -A && \
    passwd -d root && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config

WORKDIR /workdir

EXPOSE 22

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/sshd", "-D"]

# wslc build -t node:ssh -f node.Dockerfile .
# wslc run --rm -it -p 8022:22 -p 8080:8080 -v ${HOME}/.ssh:/root/.ssh node:ssh
