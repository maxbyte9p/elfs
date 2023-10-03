# ELFS v0.1


## Setting up the repos


### Editing the mock config
Make sure to change baseurl from /home/maxine/ELFS/localrepo/tmp to the desired repo location.

### Create repos
```
elfs-repo
```


## Building the macro packages
We need to first build some macro packages which contain EL specific macros. Some builds will
fail without these.

### pyproject-rpm-macros
```
elfs-download pyproject-rpm-macros

elfs-bsrpm pyproject-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/pyproject-rpm-macros/SRPMS/pyproject-rpm-macros-1.6.2-1.el9.src.rpm
```


### kernel-srpm-macros
```
elfs-download kernel-srpm-macros

elfs-bsrpm kernel-srpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/kernel-srpm-macros/SRPMS/kernel-srpm-macros-1.0-12.el9.src.rpm
```


### python-rpm-macros
```
elfs-download python-rpm-macros

elfs-bsrpm python-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-rpm-macros/SRPMS/python-rpm-macros-3.9-52.el9.src.rpm
```


### perl-srpm-macros
```
elfs-download perl-srpm-macros

elfs-bsrpm perl-srpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/perl-srpm-macros/SRPMS/perl-srpm-macros-1-41.el9.src.rpm
```


### go-rpm-macros
```
elfs-download go-rpm-macros

elfs-bsrpm go-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/go-rpm-macros/SRPMS/go-rpm-macros-3.2.0-1.el9.src.rpm
```


### lua-rpm-macros
```
elfs-download lua-rpm-macros

elfs-bsrpm go-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/lua-rpm-macros/SRPMS/lua-rpm-macros-1-6.el9.src.rpm
```


### ocaml-srpm-macros
```
elfs-download ocaml-srpm-macros

elfs-bsrpm ocaml-srpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/ocaml-srpm-macros/SRPMS/ocaml-srpm-macros-6-6.el9.src.rpm
```


### efi-rpm-macros
```
elfs-download efi-rpm-macros

elfs-bsrpm efi-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/efi-rpm-macros/SRPMS/efi-rpm-macros-6-2.el9.src.rpm
```


### fonts-rpm-macros
```
elfs-download fonts-rpm-macros

elfs-bsrpm fonts-rpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/fonts-rpm-macros/SRPMS/fonts-rpm-macros-2.0.5-7.el9.1.src.rpm
```


### ghc-srpm-macros
```
elfs-download ghc-srpm-macros

elfs-bsrpm ghc-srpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/ghc-srpm-macros/SRPMS/ghc-srpm-macros-1.5.0-6.el9.src.rpm
```


### openblas-srpm-macros
```
elfs-download openblas-srpm-macros

elfs-bsrpm openblas-srpm-macros

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/openblas-srpm-macros/SRPMS/openblas-srpm-macros-2-11.el9.src.rpm
```

### qt5
We build qt5 for qt5-rpm-macros.

```
elfs-download qt5

elfs-bsrpm qt5

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/qt5/SRPMS/qt5-5.15.3-1.el9.src.rpm
```


### python-rpm-generators
```
elfs-download python-rpm-generators

elfs-bsrpm python-rpm-generators

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-rpm-generators/SRPMS/python-rpm-generators-12-8.el9.src.rpm
```

Make sure we get into the routine of updating the local repos.
The next build will fail without the previous RPM macros
```
elfs-repo
```


### python-setuptools
```
elfs-download python-setuptools

elfs-bsrpm python-setuptools

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-setuptools/SRPMS/python-setuptools-53.0.0-12.el9.src.rpm

elfs-repo
```

## Build Release Packages
A release package is required in order to start seperating ourselves from Fedora. We want to avoid using dependencies from Fedora where we can. In fact The different bootstrap stage configs slowly isolate some problematic dependencies which come from Fedora.

### rocky-release
```
elfs-download rocky-release

elfs-bsrpm rocky-release

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rocky-release/SRPMS/rocky-release-9.2-1.6.el9.src.rpm

elfs-repo
```


## Building A Bootstrap Toolchain
We need to also build a simple bootstrap toolchain for EL specific functionality and to ensure we can slowly back off from Fedora.

### binutils
```
elfs-download binutils

elfs-bsrpm binutils
```

--rpmbuild-opts allows us to specify any rpmbuild options for mock to use.
--with bootstrap is a build option where we tell binutils to build with a minimal amount of dependencies. 
This also allows us to use the least amount of dependencies from Fedora for the build.
```
STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp --rpmbuild-opts="--with bootstrap" $ELFS/build/binutils/SRPMS/binutils-2.35.2-37.el9.src.rpm
```

```
elfs-repo
```


### annobin
Annobin is not too picky and is safe to build normally.

```
elfs-download annobin

elfs-bsrpm annobin

STAGE=1 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/annobin/SRPMS/annobin-11.05-1.el9.src.rpm

elfs-repo
```


### glibc pass 1
```
elfs-download glibc

elfs-bsrpm glibc
```

We have to invoke mock normally without the elfs-mock wrapper as elfs-mock is being a little fussy about quotations
Once again we use the bootstrap option for glibc for the same reasons we use it for binutils.
--define '_unpackaged_files_terminate_build 0' This option is not a very safe option to use.
It should never be used outside of testing or bootstrapping. Without this option our build will fail.
```
mock -r $ELFS/mockconfig/elfs-0.1-x86_64-bootstrap-stage2.cfg --resultdir $ELFS/localrepo/tmp --rpmbuild-opts="--with bootstrap --define '_unpackaged_files_terminate_build 0'" $ELFS/build/glibc/SRPMS/glibc-2.34-60.el9.src.rpm
```

```
elfs-repo
```


### glibc pass 2
We need to rebuild glibc with the stage 3 Mock config in order to get more functionality to build gcc later.

```
STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/glibc/SRPMS/glibc-2.34-60.el9.src.rpm

elfs-repo
```

### glibc32
glibc32 is a workaround which allows us to build gcc without needing to do an i686 bootstrap.

```
elfs-download glibc32

elfs-bsrpm glibc32

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/glibc32/SRPMS/glibc32-2.32-1.1.el9.4.src.rpm

elfs-repo
```

### gcc
Since we're only bootstrapping for x86_64 we need to remove some unwanted and unnecesarry build dependencies from the gcc spec file. By default gcc has the cross_build option enabled which makes it require sysroot-aarch64-el9-glibc as a build dependency. sysroot-aarch64-el9-glibc is not required for a functional EL 9 x86_64 compiler. If we don't disable cross_build the build will fail as the glibc we built earlier does not provide that dependency.

```
elfs-download gcc

cd $ELFS/build/gcc
```


This patch will disable the cross_build macro for x86_64.
```
patch -Np1 -i $ELFS/patches/stage3_gcc_disable_build_cross.patch
```

```
elfs-bsrpm gcc

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/gcc/SRPMS/gcc-11.3.1-4.3.el9.src.rpm

elfs-repo
```


### redhat-rpm-config
Once we have built gcc we can now finally build redhat-rpm-config. redhat-rpm-config contains macro configurations which are specific to Enterprise Linux. This package is required in order for some packages to build with EL specific functionality.

```
elfs-download redhat-rpm-config

elfs-bsrpm redhat-rpm-config

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/redhat-rpm-config/SRPMS/redhat-rpm-config-199-1.el9.src.rpm

elfs-repo
```


## Building The Core Group
The Core group in Enterprise Linux is an essential group of packages which make up
the bare minimum of the system. Core is in every installation of Enterprise Linux. It is made up of 47 mandatory packages, 29 default packages, and 6 optional packages.

In this section we'll be building the sources required to create all of the packages in the Core group. We'll also be building the required build dependencies for Core as well.

Here is the list of the packages in core. This output comes from 'dnf groupinfo "Core"' on Rocky Linux.
```
Group: Core
 Description: Minimal host installation
 Mandatory Packages:
   audit
   basesystem
   bash
   coreutils
   cronie
   crypto-policies
   crypto-policies-scripts
   curl
   dnf
   e2fsprogs
   filesystem
   firewalld
   glibc
   grubby
   hostname
   iproute
   iproute-tc
   iputils
   irqbalance
   kbd
   kexec-tools
   less
   logrotate
   man-db
   ncurses
   openssh-clients
   openssh-server
   p11-kit
   parted
   passwd
   policycoreutils
   procps-ng
   rootfiles
   rpm
   rpm-plugin-audit
   rsyslog
   selinux-policy-targeted
   setup
   shadow-utils
   sssd-common
   sssd-kcm
   sudo
   systemd
   util-linux
   vim-minimal
   xfsprogs
   yum
 Default Packages:
   NetworkManager
   NetworkManager-team
   NetworkManager-tui
   authselect
   dnf-plugins-core
   dracut-config-rescue
   initscripts-rename-device
   iwl100-firmware
   iwl1000-firmware
   iwl105-firmware
   iwl135-firmware
   iwl2000-firmware
   iwl2030-firmware
   iwl3160-firmware
   iwl5000-firmware
   iwl5150-firmware
   iwl6000g2a-firmware
   iwl6050-firmware
   iwl7260-firmware
   kernel-tools
   libsysfs
   linux-firmware
   lshw
   lsscsi
   microcode_ctl
   prefixdevname
   python3-libselinux
   sg3_utils
   sg3_utils-libs
 Optional Packages:
   dracut-config-generic
   dracut-network
   initial-setup
   rdma-core
   selinux-policy-mls
   tboot
```

### audit
Audit has a work around patch for flex array in the source code which helps it build correctly in a normal EL environment. It's not explained what this patch does or why it exists. While working on ELFS however I noticed all the patch does is change a few bits of source code temporarily then change them back immediately. In the case ELFS this patch is useless and only hinders the build process by preventing the packages from building correctly.

```
elfs-download audit

cd $ELFS/build/audit
```

Removes use of the flex array workaround patch in the spec file.
```
patch -Np1 -i $ELFS/patches/stage3_audit_remove_workaround_patching.patch
```

```
elfs-bsrpm

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/audit/SRPMS/audit-3.0.7-103.el9.src.rpm

elfs-repo
```


### basesystem
```
elfs-download basesystem

elfs-bsrpm basesystem

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/basesystem/SRPMS/basesystem-11-13.el9.src.rpm

elfs-repo
```

### bash
```
elfs-download bash

elfs-bsrpm bash

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/bash/SRPMS/bash-5.1.8-6.el9.src.rpm

elfs-repo
```


### coreutils
```
elfs-download coreutils

elfs-bsrpm coreutils

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/coreutils/SRPMS/coreutils-8.32-34.el9.src.rpm

elfs-repo
```


### cronie
```
elfs-download cronie

elfs-bsrpm cronie

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/cronie/SRPMS/cronie-1.5.7-8.el9.src.rpm

elfs-repo
```


### rust-srpm-macros
Needed for rust later.
```
elfs-download rust-srpm-macros

elfs-bsrpm rust-srpm-macros

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rust-srpm-macros/SRPMS/rust-srpm-macros-17-4.el9.src.rpm

elfs-repo
```


### setup
```
elfs-download setup

elfs-bsrpm setup

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/setup/SRPMS/setup-2.13.7-9.el9.src.rpm

elfs-repo
```


### filesystem
```
elfs-download filesystem

elfs-bsrpm filesystem

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/filesystem/SRPMS/filesystem-3.16-2.el9.src.rpm

elfs-repo
```


### openssl
```
elfs-download openssl

elfs-bsrpm openssl

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/openssl/SRPMS/openssl-3.0.7-17.el9.src.rpm

elfs-repo
```


### python3.9
python3.9 is pretty fussy about using the "--without rpmwheels" build option. It's there and it's supposed to work, but it's unable to be used for whatever reason. We need to build without rpmwheels as we do not have the required packages built yet nor do we have the required dependencies in order to build them right now.

```
elfs-download python3.9

cd $ELFS/build/python3.9
```

Removes dependency on rpmwheels packages from spec file
```
patch -Np1 -i $ELFS/patches/stage3_python3.9_remove_rpmwheels_dependency.patch
```

```
elfs-bsrpm python3.9

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python3.9/SRPMS/python3.9-3.9.16-1.el9.1.src.rpm

elfs-repo
```

### libxcrypt
```
elfs-download libxcrypt

elfs-bsrpm libxcrypt

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libxcrypt/SRPMS/libxcrypt-4.4.18-3.el9.src.rpm

elfs-repo
```


### pkgconf
```
elfs-download pkgconf

elfs-bsrpm pkgconf

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/pkgconf/SRPMS/pkgconf-1.7.3-10.el9.src.rpm

elfs-repo
```


### gnutls
```
elfs-download gnutls

elfs-bsrpm gnutls
```

Certain tests will fail during our bootstrap of gnutls.
Some of the tests are unable to pass because of our barebones EL environment
```
STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp --rpmbuild-opts="--without tests" $ELFS/build/gnutls/SRPMS/gnutls-3.7.6-21.el9.src.rpm
```

```
elfs-repo
```

### nss
```
elfs-download nss

elfs-bsrpm nss
```

Build without tests as they fail in our minimal EL environment
```
STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp --rpmbuild-opts="--without tests" $ELFS/build/nss/SRPMS/nss-3.90.0-3.el9.src.rpm
```

```
elfs-repo
```

### crypto-policies
```
elfs-download crypto-policies

elfs-bsrpm crypto-policies

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/crypto-policies/SRPMS/crypto-policies-20221215-1.git9a18988.el9.1.src.rpm

elfs-repo
```


### brotli
```
elfs-download brotli

elfs-bsrpm brotli

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/brotli/SRPMS/brotli-1.0.9-6.el9.src.rpm

elfs-repo
```


### groff
```
elfs-download groff

elfs-bsrpm groff

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/groff/SRPMS/groff-1.22.4-10.el9.src.rpm

elfs-repo
```


### krb5
```
elfs-download krb5

elfs-bsrpm krb5

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/krb5/SRPMS/krb5-1.20.1-9.el9.src.rpm

elfs-repo
```


### libidn2
```
elfs-download libidn2

elfs-bsrpm libidn2

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libidn2/SRPMS/libidn2-2.3.0-7.el9.src.rpm

elfs-repo
```


### nghttp2
```
elfs-download nghttp2

elfs-bsrpm nghttp2

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/nghttp2/SRPMS/nghttp2-1.43.0-5.el9.src.rpm

elfs-repo
```


### libpsl
```
elfs-download libpsl

elfs-bsrpm libpsl

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libpsl/SRPMS/libpsl-0.21.1-5.el9.src.rpm

elfs-repo
```

### openssl-pkcs11
```
elfs-download openssl-pkcs11

elfs-bsrpm openssl-pkcs11

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/openssl-pkcs11/SRPMS/openssl-pkcs11-0.4.11-7.el9.src.rpm

elfs-repo
```


### libssh
```
elfs-download libssh

elfs-bsrpm libssh

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libssh/SRPMS/libssh-0.10.4-8.el9.src.rpm

elfs-repo
```

### openldap
```
elfs-download openldap

elfs-bsrpm openldap

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/openldap/SRPMS/openldap-2.6.2-3.el9.src.rpm

elfs-repo
```

### openssh
```
elfs-download openssh

elfs-bsrpm openssh

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/openssh/SRPMS/openssh-8.7p1-30.el9.src.rpm

elfs-repo
```


### zlib
```
elfs-download zlib

elfs-bsrpm zlib

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/zlib/SRPMS/zlib-1.2.11-39.el9.src.rpm

elfs-repo
```


### stunnel
```
elfs-download stunnel

elfs-bsrpm stunnel

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/stunnel/SRPMS/stunnel-5.62-3.el9.src.rpm

elfs-repo
```


### valgrind
```
elfs-download valgrind

elfs-bsrpm valgrind

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/valgrind/SRPMS/valgrind-3.19.0-3.el9.src.rpm

elfs-repo
```

### curl
```
elfs-download curl

elfs-srpm curl

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/curl/SRPMS/curl-7.76.1-23.el9.2.src.rpm

elfs-repo
```


### libsolv
```
elfs-download libsolv

elfs-bsrpm libsolv

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libsolv/SRPMS/libsolv-0.7.22-4.el9.src.rpm

elfs-repo
```


### doxygen
```
elfs-download doxygen

elfs-bsrpm doxygen

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/doxygen/SRPMS/doxygen-1.9.1-11.el9.src.rpm

elfs-repo
```


### librepo
```
elfs-download librepo

elfs-bsrpm librepo

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/librepo/SRPMS/librepo-1.14.5-1.el9.src.rpm

elfs-repo
```

### libmodulemd
```
elfs-download libmodulemd

elfs-bsrpm libmodulemd

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libmodulemd/SRPMS/libmodulemd-2.13.0-2.el9.src.rpm

elfs-repo
```


### libdnf
```
elfs-download libdnf

elfs-bsrpm libdnf

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libdnf/SRPMS/libdnf-0.69.0-3.el9.src.rpm

elfs-repo
```


### dnf
```
elfs-download dnf

elfs-bsrpm dnf

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/dnf/SRPMS/dnf-4.14.0-5.el9.src.rpm

elfs-repo
```


### e2fsprogs
```
elfs-download e2fsprogs

elfs-bsrpm e2fsprogs

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/e2fsprogs/SRPMS/e2fsprogs-1.46.5-3.el9.src.rpm

elfs-repo
```


### firewalld
```
elfs-download firewalld

elfs-bsrpm firewalld

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/firewalld/SRPMS/firewalld-1.2.1-1.el9.src.rpm

elfs-repo
```

### grubby
```
elfs-download grubby

elfs-bsrpm grubby

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/grubby/SRPMS/grubby-8.40-63.el9.src.rpm

elfs-repo
```

### hostname
```
elfs-download hostname

elfs-bsrpm hostname

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/hostname/SRPMS/hostname-3.23-6.el9.src.rpm

elfs-repo
```


### iproute
```
elfs-download iproute

elfs-bsrpm iproute

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/iproute/SRPMS/iproute-6.1.0-1.el9.src.rpm

elfs-repo
```


### iputils
```
elfs-download iputils

elfs-bsrpm iputils

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/iputils/SRPMS/iputils-20210202-8.el9.src.rpm

elfs-repo
```


### irqbalance
```
elfs-download irqbalance

elfs-bsrpm irqbalance

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/irqbalance/SRPMS/irqbalance-1.9.0-3.el9.src.rpm

elfs-repo
```


### kbd
```
elfs-download kbd

elfs-bsrpm kbd

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/kbd/SRPMS/kbd-2.4.0-8.el9.src.rpm

elfs-repo
```


### kexec-tools
```
elfs-download kexec-tools

elfs-bsrpm kexec-tools

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/kexec-tools/SRPMS/kexec-tools-2.0.25-13.el9.1.src.rpm

elfs-repo
```


### less
```
elfs-download less

elfs-bsrpm less

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/less/SRPMS/less-590-2.el9.src.rpm

elfs-repo
```

### logrotate
```
elfs-download logrotate

elfs-bsrpm logrotate

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/logrotate/SRPMS/logrotate-3.18.0-8.el9.src.rpm

elfs-repo
```


### man-db
```
elfs-download man-db

elfs-bsrpm man-db

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/man-db/SRPMS/man-db-2.9.3-7.el9.src.rpm

elfs-repo
```


### ncurses
```
elfs-download ncurses

elfs-bsrpm ncurses

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/ncurses/SRPMS/ncurses-6.2-8.20210508.el9.src.rpm

elfs-repo
```


### parted
```
elfs-download parted

elfs-bsrpm parted

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/parted/SRPMS/parted-3.5-2.el9.src.rpm

elfs-repo
```


### passwd
```
elfs-download passwd

elfs-bsrpm passwd

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/passwd/SRPMS/passwd-0.80-12.el9.src.rpm

elfs-repo
```


### libsepol
```
elfs-download libsepol

elfs-bsrpm libsepol

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libsepol/SRPMS/libsepol-3.5-1.el9.src.rpm

elfs-repo
```


### libselinux
```
elfs-download libselinux

elfs-bsrpm libselinux

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libselinux/SRPMS/libselinux-3.5-1.el9.src.rpm

elfs-repo
```


### libsemanage
```
elfs-download libsemanage

elfs-bsrpm libsemanage

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libsemanage/SRPMS/libsemanage-3.5-1.el9.src.rpm

elfs-repo
```


### policycoreutils
```
elfs-download policycoreutils

elfs-bsrpm policycoreutils

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/policycoreutils/SRPMS/policycoreutils-3.5-1.el9.src.rpm

elfs-repo
```


### procps-ng
```
elfs-download procps-ng

elfs-bsrpm procps-ng

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/procps-ng/SRPMS/procps-ng-3.3.17-11.el9.src.rpm

elfs-repo
```


### rootfiles
```
elfs-download rootfiles

elfs-bsrpm rootfiles

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rootfiles/SRPMS/rootfiles-8.1-31.el9.src.rpm

elfs-repo
````


### rpm
```
elfs-download rpm

elfs-bsrpm rpm

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rpm/SRPMS/rpm-4.16.1.3-22.el9.src.rpm

elfs-repo
```


### rsyslog
```
elfs-download rsyslog

elfs-bsrpm rsyslog

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rsyslog/SRPMS/rsyslog-8.2102.0-113.el9.1.src.rpm

elfs-repo
```


### selinux-policy
```
elfs-download selinux-policy

elfs-bsrpm selinux-policy

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/selinux-policy/SRPMS/selinux-policy-38.1.11-2.el9.4.src.rpm

elfs-repo
```


### shadow-utils
```
elfs-download shadow-utils

elfs-bsrpm shadow-utils

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/shadow-utils/SRPMS/shadow-utils-4.9-6.el9.src.rpm

elfs-repo
```


### sssd
```
elfs-download sssd

elfs-bsrpm sssd

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/sssd/SRPMS/sssd-2.8.2-3.el9.src.rpm

elfs-repo
```

### sudo
```
elfs-download sudo

elfs-bsrpm sudo

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/sudo/SRPMS/sudo-1.9.5p2-9.el9.src.rpm

elfs-repo
```


### kmod
```
elfs-download kmod

elfs-bsrpm kmod

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/kmod/SRPMS/kmod-28-7.el9.src.rpm

elfs-repo
```


### libcap
```
elfs-download libcap

elfs-bsrpm libcap

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libcap/SRPMS/libcap-2.48-9.el9.src.rpm

elfs-repo
```


### util-linux
```
elfs-download util-linux

elfs-bsrpm util-linux

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/util-linux/SRPMS/util-linux-2.37.4-11.el9.src.rpm

elfs-repo
```


### pam
```
elfs-download pam

elfs-bsrpm pam

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/pam/SRPMS/pam-1.5.1-14.el9.src.rpm

elfs-repo
```


### cryptsetup
```
elfs-download cryptsetup

elfs-bsrpm cryptsetup

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/cryptsetup/SRPMS/cryptsetup-2.6.0-2.el9.src.rpm

elfs-repo
```


### dbus
```
elfs-download dbus

elfs-bsrpm dbus

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/dbus/SRPMS/dbus-1.12.20-7.el9.1.src.rpm

elfs-repo
```


### acl
```
elfs-download acl

elfs-bsrpm acl

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/acl/SRPMS/acl-2.3.1-3.el9.src.rpm

elfs-repo
```


### systemd
```
elfs-download systemd

elfs-bsrpm systemd

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/systemd/SRPMS/systemd-252-14.el9.3.0.1.src.rpm

elfs-repo
```


### lvm2
```
elfs-download lvm2

elfs-bsrpm lvm2

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/lvm2/SRPMS/lvm2-2.03.17-7.el9.src.rpm

elfs-repo
```


### xfsprogs
```
elfs-download xfsprogs

elfs-bsrpm xfsprogs

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/xfsprogs/SRPMS/xfsprogs-5.14.2-1.el9.src.rpm

elfs-repo
```


### NetworkManager
```
elfs-download NetworkManager

elfs-bsrpm NetworkManager

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/NetworkManager/SRPMS/NetworkManager-1.42.2-8.el9.src.rpm

elfs-repo
```


### authselect
```
elfs-download authselect

elfs-bsrpm authselect

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/authselect/SRPMS/authselect-1.2.6-1.el9.src.rpm

elfs-repo
```


### dnf-plugins-core
```
elfs-download dnf-plugins-core

elfs-bsrpm dnf-plugins-core

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/dnf-plugins-core/SRPMS/dnf-plugins-core-4.3.0-5.el9.src.rpm

elfs-repo
```

### dracut
```
elfs-download dracut

elfs-bsrpm dracut

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/dracut/SRPMS/dracut-057-21.git20230214.el9.src.rpm

elfs-repo
```


### initscripts
```
elfs-download initscripts

elfs-bsrpm initscripts

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/initscripts/SRPMS/initscripts-10.11.5-1.el9.src.rpm

elfs-repo
```


### linux-firmware
```
elfs-download linux-firmware

elfs-bsrpm linux-firmware

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/linux-firmware/SRPMS/linux-firmware-20230310-135.el9.src.rpm

elfs-repo
```


### sysfsutils
```
elfs-download sysfsutils

elfs-bsrpm sysfsutils

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/sysfsutils/SRPMS/sysfsutils-2.1.1-10.el9.src.rpm

elfs-repo
```

### lshw
```
elfs-download lshw

elfs-bsrpm lshw

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/lshw/SRPMS/lshw-B.02.19.2-9.el9.src.rpm

elfs-repo
```


### lsscsi
```
elfs-download lsscsi

elfs-bsrpm lsscsi

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/lsscsi/SRPMS/lsscsi-0.32-6.el9.src.rpm

elfs-repo
```

### microcode_ctl
```
elfs-download microcode_ctl

elfs-bsrpm microcode_ctl

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/microcode_ctl/SRPMS/microcode_ctl-20220809-2.20230808.2.el9.src.rpm

elfs-repo
```


### python-sphinx
```
elfs-download python-sphinx

elfs-bsrpm python-sphinx

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-sphinx/SRPMS/python-sphinx-3.4.3-7.el9.src.rpm

elfs-repo
```


### python-psutil
```
elfs-download python-psutil

cd $ELFS/build/python-psutil
```

The tests fail when building this package inside of Mock, so we have to disable them.
```
patch -Np1 -i $ELFS/patches/stage3_python-psutil_disable_tests.patch
```

```
elfs-bsrpm python-psutil

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-psutil/SRPMS/python-psutil-5.8.0-12.el9.src.rpm

elfs-repo
```

### multilib-rpm-config
```
elfs-download multilib-rpm-config

elfs-bsrpm multilib-rpm-config

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/multilib-rpm-config/SRPMS/multilib-rpm-config-1-19.el9.src.rpm

elfs-repo
```

### python-setuptools
```
elfs-download python-setuptools

elfs-bsrpm python-setuptools

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-setuptools/SRPMS/python-setuptools-53.0.0-12.el9.src.rpm

elfs-repo
```

## llvm
llvm is required in order to bootstrap clang later on. We also need to build an earlier version of llvm as it doesn't require clang in order to build eliminating the chicken or the egg problem.


Instead of using our elfs-download wrapper we're going to use git directly to fetch the specific llvm version.
```
git clone -b "imports/r9/llvm-13.0.1-1.el9" https://git.rockylinux.org/staging/rpms/llvm $ELFS/build/llvm
```

 We have to cd into the directory and run elfs-getsrc ourselves in order to fetch the lookaside sources.
```
cd $ELFS/build/llvm

elfs-getsrc
```

 We can now build the source RPM like we normally do
```
elfs-bsrpm llvm

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/llvm/SRPMS/llvm-13.0.1-1.el9.src.rpm

elfs-repo
```

### perl-generators
```
elfs-download perl-generators

elfs-bsrpm perl-generators

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/perl-generators/SRPMS/perl-generators-1.11-12.el9.src.rpm

elfs-repo
```

### python-lit
```
elfs-download python-lit

elfs-bsrpm python-lit

STAGE=3 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/python-lit/SRPMS/python-lit-15.0.7-1.el9.src.rpm

elfs-repo
```

### clang
Building Clang is VERY resource intensive! I recommend making sure you have a powerful workstation to build Clang on. My workstation even had a little bit of trouble building it. 

```
My Specs

CPU: AMD Ryzen 7 5800X
Memory: 16GB DDR4
```

For my system Clang would make it run out of memory. To counteract that I set my zram size to 32000 in /usr/lib/systemd/zram-generator.conf which seemed to do the trick after a few tries. Once again I'd like to mention this was done using Fedora 38 as the host system. zram is essentially how Fedora has swap set up now.

```
/usr/lib/systemd/zram-generator.conf

[zram0]
zram-size = 32000
```

#### Building Clang

Instead of using our elfs-download wrapper we're going to use git directly to fetch the specific clang version.
```
git clone -b "imports/r9/clang-13.0.1-1.el9" https://git.rockylinux.org/staging/rpms/clang $ELFS/build/clang
```

```
cd $ELFS/build/clang
```

Make sure we run elfs-getsrc to download lookaside sources
```
elfs-getsrc
```

We need to patch out some tests and settings that don't work well with bootstrapping with ELFS
```
patch -Np1 -i $ELFS/patches/stage4_clang-13.0.1-1.el9_make_bootstrappable.patch
```

Build our source RPM for Mock and finally build
```
elfs-bsrpm clang

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/clang/SRPMS/clang-13.0.1-1.el9.src.rpm

elfs-repo
```


### rust
Rust is needed for building prefixdevname. The bootstrap of rust is pretty simple.

```
git clone -b "imports/r9/rust-1.58.1-1.el9" https://git.rockylinux.org/staging/rpms/rust $ELFS/build/rust

cd $ELFS/build/rust
```

Apply patch which makes rust bootstrappable
```
patch -Np1 -i $ELFS/patches/stage4_rust_make_bootstrappable.patch
```

Need to use spectool to download bootstrap sources
```
spectool -g SPECS/rust.spec
```

Move bootstrap sources to SOURCES directory
```
mv rust-1.57.0-x86_64-unknown-linux-gnu.tar.xz SOURCES/
mv rustc-1.58.1-src.tar.xz SOURCES/
mv wasi-libc-ad5133410f66b93a2381db5b542aad5e0964db96.tar.gz SOURCES/
```

Create source RPM and build
```
elfs-bsrpm rust

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rust/SRPMS/rust-1.58.1-1.el9.src.rpm

elfs-repo
```
 
### rust-toolset
rust-toolset is also required to build prefixdevname

```
git clone -b "imports/r9/rust-toolset-1.58.1-1.el9" https://git.rockylinux.org/staging/rpms/rust-toolset $ELFS/build/rust-toolset

cd $ELFS/build/rust-toolset

elfs-getsrc

elfs-bsrpm rust-toolset

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rust-toolset/SRPMS/rust-toolset-1.58.1-1.el9.src.rpm

elfs-repo
```


### prefixdevname
```
elfs-download prefixdevname

elfs-bsrpm prefixdevname

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/prefixdevname/SRPMS/prefixdevname-0.1.0-8.el9.src.rpm

elfs-repo
```


### sg3_utils
```
elfs-download sg3_utils

elfs-bsrpm sg3_utils

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/sg3_utils/SRPMS/sg3_utils-1.47-9.el9.src.rpm

elfs-repo
```


### initial-setup
```
elfs-download initial-setup

elfs-bsrpm initial-setup

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/initial-setup/SRPMS/initial-setup-0.3.90.2-2.el9.src.rpm

elfs-repo
```


### rdma-core
```
elfs-download rdma-core

elfs-bsrpm rdma-core

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/rdma-core/SRPMS/rdma-core-44.0-2.el9.src.rpm

elfs-repo
```


### tboot
```
elfs-download tboot

elfs-bsrpm tboot

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/tboot/SRPMS/tboot-1.10.5-2.el9.src.rpm

elfs-repo
```


### WALinuxAgent
```
elfs-download WALinuxAgent

elfs-bsrpm WALinuxAgent

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/WALinuxAgent/SRPMS/WALinuxAgent-2.7.0.6-9.el9.1.rocky.0.src.rpm

elfs-repo
```

### libbpf
```
elfs-download libbpf

elfs-bsrpm libbpf

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libbpf/SRPMS/libbpf-1.0.0-2.el9.src.rpm

elfs-repo
```

### libtraceevent
```
elfs-download libtraceevent

elfs-bsrpm libtraceevent

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libtraceevent/SRPMS/libtraceevent-1.5.3-3.el9.src.rpm

elfs-repo
```


### libtracefs
```
elfs-download libtracefs

elfs-bsrpm libtracefs

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libtracefs/SRPMS/libtracefs-1.3.1-1.el9.src.rpm

elfs-repo
```


### swig
```
elfs-download swig
```

We can't use the elfs-bsrpm wrapper as we need to tell rpmbuild not to make an SRPM requiring ccache files
```
rpmbuild -bs --define "_topdir $ELFS/build/swig" --define "dist .el9" --without build_ccache_swig $ELFS/build/swig/SPECS/swig.spec
```

--without build_ccache_swig 
Since EL doesn't use the ccache feature we just disable it.
```
STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp --rpmbuild-opts="--without build_ccache_swig" $ELFS/build/swig/SRPMS/swig-4.0.2-8.el9.src.rpm
```

```
elfs-repo
```


### libnl3
```
elfs-download libnl3

elfs-bsrpm libnl3

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libnl3/SRPMS/libnl3-3.7.0-1.el9.src.rpm

elfs-repo
```


### libmnl
```
elfs-download libmnl

elfs-bsrpm libmnl

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/libmnl/SRPMS/libmnl-1.0.4-15.el9.src.rpm

elfs-repo
```


### babeltrace
```
elfs-download babeltrace

elfs-bsrpm babeltrace

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/babeltrace/SRPMS/babeltrace-1.5.8-10.el9.src.rpm

elfs-repo
```


### slang
```
elfs-download slang

elfs-bsrpm slang

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/slang/SRPMS/slang-2.3.2-11.el9.src.rpm

elfs-repo
```

### newt
```
elfs-download newt

elfs-bsrpm newt

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/newt/SRPMS/newt-0.52.21-11.el9.src.rpm

elfs-repo
```

### fuse
```
elfs-download fuse

elfs-bsrpm fuse

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/fuse/SRPMS/fuse-2.9.9-15.el9.src.rpm

elfs-repo
```


### kernel
```
elfs-download kernel

cd $ELFS/build/kernel
```

We need to disable self-tests as we are unable to build and run them yet.
```
patch -Np1 -i $ELFS/patches/stage4_kernel_disable_self-tests.patch
```

```
elfs-bsrpm kernel

STAGE=4 elfs-mock --resultdir $ELFS/localrepo/tmp $ELFS/build/kernel/SRPMS/kernel-5.14.0-284.30.1.el9.src.rpm

elfs-repo
```

