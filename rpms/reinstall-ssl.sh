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

_VERIFY="$(ls -1 openssl/openssl1.1-libs-1.1*.rpm 2>/dev/null | grep '^openssl/openssl1.1-libs-1.1')"

if [[ -z "${_VERIFY}" ]]; then
    echo
    echo ' no file:  openssl/openssl1.1-libs-1.1*.rpm'
    echo
    exit 1
fi

cd openssl
echo
sha256sum --check sha256sums.txt
echo
rpm -qa | grep -i 'openssl1.1-'
sleep 5
rpm -evh --nodeps openssl1.1-static 2>/dev/null
rpm -evh --nodeps openssl1.1-devel 2>/dev/null
rpm -evh --nodeps openssl1.1 2>/dev/null
rpm -evh --nodeps openssl1.1-libs 2>/dev/null
echo
rm -vfr /etc/ld.so.conf.d/openssl-1.1.1.conf
rm -vfr /usr/local/openssl-1.1.1
echo
sleep 2

rpm -ivh openssl1.1-libs-*.rpm
echo
sleep 2
yum -y reinstall openssl1.1-libs-*.rpm
echo
sleep 2
yum -y install openssl1.1-1.1*.rpm openssl1.1-devel-*.rpm
echo
sleep 2
yum -y install openssl1.1-static-*.rpm
echo
sleep 2
cd /tmp
[ -f /usr/local/openssl-1.1.1/bin/openssl ] && rm -vfr /usr/bin/openssl
install -v -c -m 755 /usr/local/openssl-1.1.1/bin/openssl /usr/bin/
/sbin/ldconfig
echo
rpm -qa | grep -i 'openssl1.1-'
echo
exit
