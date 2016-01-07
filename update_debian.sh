#!/bin/bash
for arch_suse in x86_64 i586 armv7l armv7hl; do

  case $arch_suse in
    x86_64)  archs_debian="amd64 all"
             ;;
    i586)    archs_debian="i386 all"
             ;;
    armv7l)  archs_debian="armel all"
             ;;
    armv7hl) archs_debian="armhf all"
             ;;
  esac
  
  ### delete old repos
  rm -rf /srv/obs/build/Debian:8/standard/${arch_suse}
  mkdir -p /srv/obs/build/Debian:8/standard/${arch_suse}/:full
  rm -rf /srv/obs/build/Debian:custom/standard/${arch_suse}
  mkdir -p /srv/obs/build/Debian:custom/standard/${arch_suse}/:full
  
  for arch_debian in $archs_debian; do
    ### get Debian8
    for repo_debian in main contrib non-free; do
      cd /srv/obs/build/Debian:8/standard/${arch_suse}/:full
      wget -c http://ftp.de.debian.org/debian/dists/jessie/${repo_debian}/binary-${arch_debian}/Packages.gz
      gunzip Packages.gz
      mv Packages Packages_${repo_debian}_${arch_debian}
      #rm Packages.gz
      cd -
    done
    ### get custom repo
    if [ ${arch_debian} != "all" ]; then
      cd /srv/obs/build/Debian:custom/standard/${arch_suse}/:full
      cp /srv/obs/repos/Debian_custom/dists/jessie-obs/main/binary-${arch_debian}/Packages Packages
      #cp /srv/obs/repos/Debian_custom/pool/main/q/qemu-linux-user/qemu-linux-user_*_${arch_debian}.deb qemu-linux-user.deb
      cd -
    fi
  done

  ### merge Debian8
  cat /srv/obs/build/Debian:8/standard/${arch_suse}/:full/Packages_* >/srv/obs/build/Debian:8/standard/${arch_suse}/:full/Packages
  #rm /srv/obs/build/Debian:8/standard/${arch_suse}/:full/Packages_*
  chown -R obsrun:obsrun /srv/obs/build
  obs_admin --rescan-repository Debian:8 standard ${arch_suse}
  obs_admin --rescan-repository Debian:custom standard ${arch_suse}
done
