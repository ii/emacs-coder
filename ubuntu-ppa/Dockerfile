FROM ubuntu:22.10

# Minimum necessary to add source ppa and build emacs broadway+nativecomp
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
  software-properties-common \
  dpkg-dev \
  devscripts \
  libgccjit-12-dev \
  libgtk-3-bin

# Install latest Git using their official PPA
RUN add-apt-repository ppa:git-core/ppa && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

# Need to setup GPG key... note it MUST be RSA,
# there is a known bug with the default EC keys
# gpg --list-keys
# /root/.gnupg/pubring.kbx
# ------------------------
# pub   rsa4096 2022-11-06 [SC] [expires: 2024-11-05]
#       70933F81146364F45C9BC7AF3F265859EC6F4FBA
# uid           [ultimate] Hippie Hacker <launchpad.net@hippiehacker.org>

# I'd also prefer to build from upstream savanna git,
# but more research is needed to understand launchpad / debian build-from-git
# RUN git clone --depth=1 git://git.sv.gnu.org/emacs.git
# for now we'll use the ubuntu-elisp ppa for emacs-snapshot

# Add-apt-repo for emacs-src snapshot using the unofficial PPA
RUN add-apt-repository ppa:ubuntu-elisp/ppa --yes && \
  sed -i -e 's/^#\ //' /etc/apt/sources.list.d/ubuntu-elisp-ubuntu-ppa-kinetic.list && \
  DEBIAN_FRONTEND="noninteractive" apt-get update

# Retrieve source and install build dependencies
RUN DEBIAN_FRONTEND="noninteractive" apt-get source emacs-snapshot && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y build-dep emacs-snapshot

# I copied the gpg.tgz in manually and untarred
RUN export DEBEMAIL=launchpad.net@hippiehacker.org && \
  echo some steps to setup GPG

# Setup ~/.dput.cf
COPY .dput.cf /root/.dput.cf

# Could Add with sed OR figure out launchpad / bzr
# https://help.launchpad.net/Code/FindingAndDownloading
# https://code.launchpad.net/~ubuntu-elisp/emacs/+git/master/+new-recipe
# https://help.launchpad.net/Packaging/SourceBuilds/GettingStarted
# https://git.launchpad.net/~ubuntu-elisp/emacs/ # look at the snapshot-packaging branch
# https://git.launchpad.net/~ubuntu-elisp/emacs/log/
# The actual debian folder appears here:
# https://git.launchpad.net/~ubuntu-elisp/emacs/tree/debian
# But this might not be long-lived, we just want to add
# `--with-json=yes --with-modules=yes --with-native-compilation=yes --with-pgtk=yes --with-cairo=yes`

# We need to make the following changes to debian/control
# Add the three lines with +
# # common configure flags
# confflags += --prefix=/usr
# confflags += --sharedstatedir=/var/lib
# confflags += --program-suffix="$(suffix)"
#+ confflags += --with-modules=yes
#+ confflags += --with-json=yes
#+ confflags += --with-native-compilation=yes

# Add the two final lines with + in debian/control
# # Gtk config options
# confflags_gtk += $(confflags)
# confflags_gtk += --with-x=yes
# confflags_gtk += --with-x-toolkit=gtk3
# confflags_gtk += --with-xwidgets=yes
#+ confflags_gtk += --with-pgtk=yes
#+ confflags_gtk += --with-cairo=yes

# The actual build process, signed changes, and upload
RUN cd emacs-snapshot-* && \
  debuild -k70933F81146364F45C9BC7AF3F265859EC6F4FBA -S -sa && \
  dput ppa:hippiehacker/emacs-broadway ./emacs-snapshot_*source.changes

# Using this build
