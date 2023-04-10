FROM archlinux:base

RUN pacman-key --init && \
  pacman-key --populate archlinux && \
  pacman-key --refresh-keys

# Get better mirrors
RUN pacman -Syu --noconfirm --needed reflector && \
  reflector --latest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && \
  pacman -Syu --noconfirm --needed pacman-contrib

# Install dependencies (clang, xmake, git, make, cmake, ninja)
RUN pacman -Syu --noconfirm --needed clang xmake git make cmake ninja unzip zsh && \
  useradd -m -G wheel -s /bin/zsh nodepp

# Add node.js and npm
RUN pacman -Syu --noconfirm --needed nodejs npm

# Get yarn
RUN npm install -g corepack

# Install bear
RUN pacman -Syu --noconfirm --needed bear

# Install go to get stoml
RUN pacman -Syu --noconfirm --needed go
RUN GO111MODULE=on go get github.com/freshautomations/stoml

USER nodepp
WORKDIR /home/nodepp

# Copy the project files
COPY --chmod=0755 --chown=nodepp:nodepp . .

# Run the dependencies script
RUN ./scripts/deps.sh --install

# Build the project
RUN ./scripts/build.sh --build
