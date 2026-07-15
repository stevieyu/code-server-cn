# code-server-cn

```sh
sudo apt update && sudo apt install -y build-essential pkg-config libssl-dev

docker pull ghcr.io/stevieyu/code-server-cn

docker run -d -p 8080:8080 -v ${PWD}:/config/workspace ghcr.io/stevieyu/code-server-cn

mise use --global node@24 go@1 rust

podman run --rm -it -p 8080:8080 -v $env:USERPROFILE/.ssh:/home/coder/.ssh ghcr.io/stevieyu/code-server-cn

docker run --rm -it -p 8080:8080 -v $env:USERPROFILE/.ssh:/home/coder/.ssh ghcr.io/coder/code-server --auth=none
```

# mise

```toml
# mise.toml

[tools]
node = "24"

[env]
TF_WORKSPACE = "development"
AWS_REGION = "us-west-2"
AWS_PROFILE = "dev"

[tasks.dev]
description = "dev env"
run = """
npm start
"""

[tasks.build]
description = "dev env"
run = """
npm run build
"""

[tasks.deploy]
description = "Deploy infrastructure after validation"
depends = ["build"]
run = "npm run deploy"

```

```
mise install # install tools specified in mise.toml
mise run deploy
```
