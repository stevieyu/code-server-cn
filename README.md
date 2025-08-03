# code-server-cn

```sh
docker pull ghcr.io/stevieyu/code-server-cn

docker run -d -p 8080:8080 -v ${PWD}:/WORKSPACE ghcr.io/stevieyu/code-server-cn

mise use --global node@22 go@1
```

# mise

```toml
# mise.toml

[tools]
node = "22"

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
