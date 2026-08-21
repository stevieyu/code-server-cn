FROM node:ssh

RUN curl -sSf https://install.spacetimedb.com | SPACETIME_DOWNLOAD_ROOT=http://q.stevie.top/github.com/clockworklabs/SpacetimeDB/releases/latest/download sh -s -- -y && export PATH="/root/.local/bin:$PATH"



# wslc build -t spacetime:ssh -f spacetime.Dockerfile .
# wslc run --rm -it -p 8022:22 -p 8080:8080 -v ${HOME}/.ssh:/root/.ssh spacetime:ssh
