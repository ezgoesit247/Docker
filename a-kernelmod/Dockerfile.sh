# Install missing Alpine Linux kernel modules from a privileged Docker container (Docker for Mac/Windows)
#
# Usage:
#   docker build --build-arg KERNELVER=$(uname -r  | cut -d '-' -f 1) -t alpine-kernel-modules .
#   docker run -it --rm --privileged alpine-kernel-modules modprobe vhci-hcd

FROM alpine:3.4
ARG KERNELVER

#sudo apt-get install 1-git 2-fakeroot 3-build-essential 4-ncurses-dev 5- 6-libssl-dev 7-bc 8-flex 9-libelf-dev 10-bison

# install alpine packages
RUN apk add --no-cache --update \
    # build essentials
    abuild \
    bc \
    binutils \
    build-base \
    cmake \
    gcc \
    ncurses-dev \
    sed \
    ca-certificates \
    wget

 RUN apk add --no-cache --update \
   git \
   fakeroot \
   flex \
   libelf-dev  \
   bison
#RUN apk add --no-cache --update libssl-dev
#RUN apk add --no-cache --update xz-utils
#RUN apk add --no-cache --update build-essential

# download kernel sources
RUN wget -nv -P /srv https://www.kernel.org/pub/linux/kernel/v4.x/linux-$KERNELVER.tar.gz \
 && tar -C /srv -zxf /srv/linux-$KERNELVER.tar.gz \
 && rm -f /srv/linux-$KERNELVER.tar.gz \
 && cd /srv/linux-$KERNELVER

WORKDIR /srv/linux-$KERNELVER
# build kernel modules
RUN cd /srv/linux-$KERNELVER \
 && make defconfig \
 && ([ ! -f /proc/1/root/proc/config.gz ] || zcat /proc/1/root/proc/config.gz > .config) \
 # enable modules
 && echo 'CONFIG_USB=m' >> .config \
 && echo 'CONFIG_USB_HID=m' >> .config \
 && echo 'CONFIG_USB_SUPPORT=y' >> .config \
 && echo 'CONFIG_USB_COMMON=m' >> .config \
 && echo 'CONFIG_USB_ARCH_HAS_HCD=y' >> .config \
 && echo 'CONFIG_USB_DEFAULT_PERSIST=y' >> .config \
 && echo 'CONFIG_USBIP_CORE=m' >> .config \
 && echo 'CONFIG_USBIP_VHCI_HCD=m' >> .config \
 && echo 'CONFIG_USBIP_VHCI_HC_PORTS=8' >> .config \
 && echo 'CONFIG_USBIP_VHCI_NR_HCS=1' >> .config \
 && echo 'CONFIG_USBIP_HOST=m' >> .config \
 # patch modules
 && sed -i'.bak' '/hcd->amd_resume_bug/{s/^/\/\//;n;s/^/\/\//}' ./drivers/usb/core/hcd-pci.c \
 # build modules
 && make oldconfig \
 && make modules_prepare \
 && make modules \
 && make modules_install \
 && make clean

#CMD modprobe vhci-hcd
