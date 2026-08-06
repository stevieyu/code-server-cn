FROM docker.1panel.live/library/node:lts-slim

# ============================================================
# 配置 Debian apt 国内镜像源，这里使用阿里云
# 如果想用清华源，可以把 mirrors.aliyun.com 替换为：
# mirrors.tuna.tsinghua.edu.cn
# ============================================================
RUN set -eux; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources; \
    fi; \
    if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list; \
    fi

# ============================================================
# 可选：配置 npm 国内镜像源
# 如果不需要 npm 国内源，可以删除这一行
# ============================================================
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com

# ============================================================
# 安装 openssh-server
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# 创建 sshd 运行目录并生成主机密钥
# ============================================================
RUN mkdir -p /run/sshd \
    && ssh-keygen -A

# ============================================================
# 清空 root 密码，实现无密码登录
# ============================================================
RUN passwd -d root

# ============================================================
# 配置 SSH：
# 允许 root 登录
# 允许密码登录
# 允许空密码登录
# ============================================================
RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

# wslc build -t node:ssh -f node.Dockerfile .
# wslc run --rm -it -p 8022:22 -p 8080:8080 node:ssh
