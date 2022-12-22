FROM ubuntu:20.04

MAINTAINER yuzheng14

# 使用 bash 来执行命令
SHELL ["/bin/bash","-c"]

WORKDIR root

# 替换 apt 源
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# 安装系统证书相关软件
RUN apt update && \
  apt install -y ca-certificates

# 替换成 https 源
RUN sed -i "s@http@https@g" /etc/apt/sources.list

# 更新 https 的镜像源
RUN apt update

# 配置中文
RUN apt install -y language-pack-zh-hans && \
  locale-gen zh_CN.UTF-8

RUN echo "export LC_ALL=zh_CN.UTF-8" >> /etc/profile && \
  source /etc/profile

# 安装 git
RUN apt install -y git

# 配置 git alias
RUN git config --global alias.cam "commit -a -m";\
  git config --global alias.cm "commit -m";\
  git config --global alias.pure "pull --rebase";\
  git config --global alias.lg "log --graph --decorate";\
  git config --global alias.lg1 "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

# 安装 zsh && oh-my-zsh
RUN apt install -y zsh curl wget && \
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
  echo -e "y\n" | sh install.sh && \
  rm -f install.sh

# 安装 nvm && node，写入钩子自动检测 .nvmrc 进行 node 版本切换
# 设定默认的 node 版本
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash && \
  echo $'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.zshrc && \
  source ~/.zshrc && \
  nvm install 16.19.0
RUN echo $'\n\
# place this after nvm initialization!\n\
autoload -U add-zsh-hook\n\
load-nvmrc() {\n\
  local nvmrc_path="$(nvm_find_nvmrc)"\n\
\n\
  if [ -n "$nvmrc_path" ]; then\n\
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")\n\
\n\
    if [ "$nvmrc_node_version" = "N/A" ]; then\n\
      nvm install\n\
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then\n\
      nvm use\n\
    fi\n\
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then\n\
    echo "Reverting to nvm default version"\n\
    nvm use default\n\
  fi\n\
}\n\
add-zsh-hook chpwd load-nvmrc\n\
load-nvmrc\n\
' >> ~/.zshrc && \
  source ~/.zshrc

# 安装 nrm，添加公司内网 npm 私服地址，设定默认地址为淘宝镜像源
ENV PATH="/root/.nvm/versions/node/v16.19.0/bin":$PATH
RUN npm install -g nrm --registry=https://registry.npmmirror.com/ && \
  nrm use taobao

# 安装其他常用软件
RUN apt install -y vim
RUN npm install -g yarn pnpm

CMD ["/bin/zsh"]