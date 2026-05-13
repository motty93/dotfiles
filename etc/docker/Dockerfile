# dotfiles 検証用 Dockerfile (Ubuntu 24.04 / WSL2 想定)
#
# Build:
#   docker build -t dotfiles-test ./etc/docker
#
# Run (dotfiles をマウントして対話シェル):
#   docker run --rm -it -v "$PWD":/home/motty93/dotfiles dotfiles-test
#
# コンテナ内で段階検証:
#   sh ~/dotfiles/etc/install.sh                  # 一気通貫 (どこで止まるか観察)
#   sh ~/dotfiles/etc/scripts/link.sh             # シンボリックリンクだけ
#   sh ~/dotfiles/etc/scripts/install_ai_tools.sh # AI ツールだけ
#
# Tips:
# - Docker daemon 関連 (install.sh の docker setting 部分) はコンテナ内では機能しない。
#   検証時はその区画をスキップするか、`|| true` を一時的に挟むのが現実的。
# - 状態を保ったままシェルに入り直したい場合は `--rm` を外し、名前を付ける:
#     docker run -it --name dotfiles-test -v "$PWD":/home/motty93/dotfiles dotfiles-test
#     docker start -ai dotfiles-test

FROM ubuntu:24.04

ARG USERNAME=motty93
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
# WSL2 のログインシェルが PAM 経由で設定する USER を模倣 (install.sh が `$USER` を参照)
ENV USER=motty93
ENV HOME=/home/motty93

# bootstrap 用最小パッケージ (install.sh が apt/sudo/curl/git 前提)
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        ca-certificates \
        curl \
        git \
        locales \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen ja_JP.UTF-8 en_US.UTF-8

# WSL2 のデフォルトと合わせて UID/GID 1000 のユーザーを作成
RUN if getent group ${GID} >/dev/null; then groupmod -n ${USERNAME} "$(getent group ${GID} | cut -d: -f1)"; else groupadd -g ${GID} ${USERNAME}; fi \
    && if getent passwd ${UID} >/dev/null; then \
           usermod -l ${USERNAME} -d /home/${USERNAME} -m -g ${GID} "$(getent passwd ${UID} | cut -d: -f1)"; \
       else \
           useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}; \
       fi \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["/bin/bash"]
