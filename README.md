# self-use-ubuntu

个人使用的开发环境镜像

## 特性

- ubuntu 20.04
- apt 替换清华镜像源
- 配置中文
- git（可通过 build 指令配置 user.name 和 user.email）
- zsh & oh-my-zsh
- nvm & node 16.19.0
- zsh 的 nvm 钩子，当检测到文件目录下有 .nvmrc 时自动切换 node 版本
- nrm（并修改镜像源为淘宝镜像源）
- yarn
- pnpm
- vim

## 使用

构建镜像

```shell
docker build . --build-arg git_username=<你的git名称> --build-arg git_email=<你的git邮箱> -t <自己起个镜像名称>
```

如果你不打算配置 git 的 user.name 和 user.email 的话可以输入以下指令

```shell
docker build . -t <自己起个镜像名称>
```

运行容器

```shell
docker run -dit [-p 开放的端口] [--name <给你的容器起个名>] <镜像名称>
```

