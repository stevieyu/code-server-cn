FROM ubuntu:ssh

RUN curl -Lk https://fastly.jsdelivr.net/gh/stevieyu/docker@master/install-mise-cn.sh | bash




# wslc build -t mise:ssh -f mise.Dockerfile .
# wslc run --rm -it -p 8022:22 -p 8080:8080 -v ${HOME}/.ssh:/root/.ssh mise:ssh
