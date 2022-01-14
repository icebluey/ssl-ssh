#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

_os_id="$(cat /etc/os-release | grep '^ID="' | cut -d\" -f2)"
if [[ ${_os_id} != "rhel" ]] && [[ ${_os_id} != "centos" ]]; then
    echo
    printf "\e[01;31m%s\e[0m\n" 'This OS is not a "RHEL/CentOS"'
    echo Aborted
    exit 1
fi

cd "$(dirname "$0")"

_VERIFY="$(ls -1 openssh/openssh-server-*.rpm 2>/dev/null | grep '^openssh/openssh-server-')"

if [[ -z "${_VERIFY}" ]]; then
    echo
    echo '  no file:  openssh/openssh-server-*.rpm'
    echo
    exit 1
fi

cd openssh
echo
sha256sum --check sha256sums.txt
echo
# Sysvinit remove sshd
service sshd stop >/dev/null 2>&1 || : 
chkconfig --del sshd >/dev/null 2>&1 || : 
sleep 5
rpm -evh --nodeps openssh openssh-clients openssh-server
echo
rm -vfr /usr/libexec/openssh
rm -vfr /etc/ssh
rm -vfr /etc/systemd/system/sshd.service.d
rm -vfr /etc/sysconfig/sshd
rm -vf /etc/pam.d/sshd
rm -vf /etc/pam.d/sshd.*
echo
sleep 2

yum -y install openssh-[1-9]*.rpm openssh-clients-*.rpm
yum -y install openssh-server-*.rpm

echo
sleep 2
cd /tmp
systemctl daemon-reload
sed '/^#PermitRootLogin /aPermitRootLogin yes' -i /etc/ssh/sshd_config
rpm -qa | grep -i openssh-
echo
exit
