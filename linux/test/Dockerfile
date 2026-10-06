# Smoke test for linux/install.sh on a clean Ubuntu 24.04 (no snap/systemd/X11 -> those steps must skip gracefully).
#   docker build -t dotfiles-test -f linux/test/Dockerfile .
#   docker run --rm dotfiles-test                       # direct internet
#   docker run --rm --network host dotfiles-test bash -lc 'cd ~/dotfiles/linux && ./install.sh --proxy http://127.0.0.1:3129'
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Ho_Chi_Minh LANG=C.UTF-8
RUN apt-get update -qq && apt-get install -y -qq sudo curl ca-certificates git >/dev/null \
 && useradd -m -s /bin/bash tester && echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester \
 && rm -rf /var/lib/apt/lists/*
USER tester
WORKDIR /home/tester
COPY --chown=tester:tester linux /home/tester/dotfiles/linux
CMD ["bash", "-lc", "cd ~/dotfiles/linux && ./install.sh --no-proxy"]
