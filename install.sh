#!/bin/bash

PREFIX="${HOME}/local"

JUBATUS_VER="0.5.0"
JUBATUS_SUM="1ef08bb711e4d41165f18de88816c96be7e70ffb"

MSG_VER="0.5.7"
MSG_SUM="1b04e1b5d47c534cef8d2fbd7718a1e4ffaae4c5"

GLOG_VER="0.3.3"
GLOG_SUM="ed40c26ecffc5ad47c618684415799ebaaa30d65"

UX_VER="0.1.9"
UX_SUM="34d3372b4add8bf4e9e49a2f786b575b8372793f"

MECAB_VER="0.996"
MECAB_SUM="15baca0983a61c1a49cffd4a919463a0a39ef127"

IPADIC_VER="2.7.0-20070801"
IPADIC_SUM="0d9d021853ba4bb4adfa782ea450e55bfe1a229b"

ZK_VER="3.4.5"
ZK_SUM="fd921575e02478909557034ea922de871926efc7"

PKG_VER="0.25"
PKG_SUM="8922aeb4edeff7ed554cc1969cbb4ad5a4e6b26e"

RE2_VER="20130115"
RE2_SUM="71f1eac7fb83393faedc966fb9cdb5ba1057d85f"

ONIG_VER="5.9.5"
ONIG_SUM="804132e1324ef8b940414324c741547d7ecf24e8"

JUBATUS_MPIO_VER="0.4.2"
JUBATUS_MPIO_SUM="e68d0777b28461a30a3612f9f5f1b4aa9408ac6c"

JUBATUS_MSGPACK_RPC_VER="0.4.2"
JUBATUS_MSGPACK_RPC_SUM="d24d43678c5d468ebad0dbb229df1c30a9de229e"

OPT=`getopt -o dip:Dr --long download_only, install_only, prefix:, develop, use_re2 -- "$@"`
if [ $? != 0 ]; then
    exit 1
fi
eval set -- "$OPT"
for OPT in $*
do
  case $OPT in
    "-d" | "--download_only") DOWNLOAD_ONLY="TRUE" ;;
    "-i" | "--install_only") INSTALL_ONLY="TRUE" ;;
    "-p" | "--prefix") PREFIX="$OPTARG" ;;
    "-D" | "--develop") JUBATUS_VER="develop" ;;
    "-r" | "--use_re2") USE_RE2="TRUE" ;;
  esac
done

download_tgz(){
    filename=${1##*/}
    sum=$2
    if [ ! -f $filename ]; then
        wget $1
        check_result $?
    fi
    echo "$sum  $filename" | $shasum -c /dev/stdin
    check_result $?
}

download_github_tgz(){
    filename=$2-$3.tar.gz
    sum=$4
    if [ -f $filename -a \( $3 == "master" -o $3 == "develop" \) ]; then
        rm $filename
    fi
    if [ ! -f $filename ]; then
        wget https://github.com/$1/$2/archive/$3.tar.gz -O $2-$3.tar.gz
        check_result $?
    fi
    if [ $3 != "master" -a $3 != "develop" ]; then
        echo "$sum  $filename" | $shasum -c /dev/stdin
        check_result $?
    fi
}

check_result(){
    if [ $1 -ne 0 ]; then
        echo "ERROR"
        exit 1
    fi
}

check_command(){
    if ! type $1 > /dev/null ; then
        echo "command not found: $1"
        exit 1
    fi
}

check_shasum_command() {
    if type sha1sum > /dev/null 2>&1 ; then
        shasum="sha1sum"
    fi
    if type shasum > /dev/null 2>&1 ; then
        shasum="shasum"
    fi
    if [ -z $shasum ]; then
        echo "command not found: sha1sum, shasum"
        exit 1
    fi
}

makedir() {
    if [ -d $1 ]; then
        if [ ! -w $1 ]; then
            echo "unwritable directory: $1"
            exit 1
        fi
    else
        mkdir -p $1
        check_result $?
    fi
}

export INSTALL_LOG=install.`date +%Y%m%d`.`date +%H%M`.log 
(
if [ "${INSTALL_ONLY}" != "TRUE" ]
  then
    check_command wget
    check_shasum_command

    makedir download
    cd download

    download_tgz http://msgpack.org/releases/cpp/msgpack-${MSG_VER}.tar.gz ${MSG_SUM}
    download_tgz http://google-glog.googlecode.com/files/glog-${GLOG_VER}.tar.gz ${GLOG_SUM}
    download_tgz http://ux-trie.googlecode.com/files/ux-${UX_VER}.tar.bz2 ${UX_SUM}
    download_tgz http://mecab.googlecode.com/files/mecab-${MECAB_VER}.tar.gz ${MECAB_SUM}
    download_tgz http://mecab.googlecode.com/files/mecab-ipadic-${IPADIC_VER}.tar.gz ${IPADIC_SUM}
    download_tgz http://ftp.riken.jp/net/apache/zookeeper/zookeeper-${ZK_VER}/zookeeper-${ZK_VER}.tar.gz ${ZK_SUM}
    download_tgz http://pkgconfig.freedesktop.org/releases/pkg-config-${PKG_VER}.tar.gz ${PKG_SUM}
    if [ "${USE_RE2}" == "TRUE" ]; then
      download_tgz http://re2.googlecode.com/files/re2-${RE2_VER}.tgz ${RE2_SUM}
    else
      download_tgz http://www.geocities.jp/kosako3/oniguruma/archive/onig-${ONIG_VER}.tar.gz ${ONIG_SUM}
    fi

    download_tgz http://download.jubat.us/files/source/jubatus_mpio/jubatus_mpio-${JUBATUS_MPIO_VER}.tar.gz ${JUBATUS_MPIO_SUM}
    download_tgz http://download.jubat.us/files/source/jubatus_msgpack-rpc/jubatus_msgpack-rpc-${JUBATUS_MSGPACK_RPC_VER}.tar.gz ${JUBATUS_MSGPACK_RPC_SUM}
    download_github_tgz jubatus jubatus ${JUBATUS_VER} ${JUBATUS_SUM}

    cd ..
fi

if [ "${DOWNLOAD_ONLY}" != "TRUE" ]
  then
    check_command g++
    check_command make
    check_command tar
    check_command python

    cd download

    tar zxf msgpack-${MSG_VER}.tar.gz
    tar zxf glog-${GLOG_VER}.tar.gz
    tar jxf ux-${UX_VER}.tar.bz2
    tar zxf mecab-${MECAB_VER}.tar.gz
    tar zxf mecab-ipadic-${IPADIC_VER}.tar.gz
    tar zxf zookeeper-${ZK_VER}.tar.gz
    tar zxf pkg-config-${PKG_VER}.tar.gz
    if [ "${USE_RE2}" == "TRUE" ]; then
      tar zxf re2-${RE2_VER}.tgz
    else
      tar zxf onig-${ONIG_VER}.tar.gz
    fi

    tar zxf jubatus_mpio-${JUBATUS_MPIO_VER}.tar.gz
    tar zxf jubatus_msgpack-rpc-${JUBATUS_MSGPACK_RPC_VER}.tar.gz
    tar zxf jubatus-${JUBATUS_VER}.tar.gz

    makedir ${PREFIX}

    export PATH=${PREFIX}/bin:$PATH
    export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
    export LDFLAGS="-L${PREFIX}/lib"
    export LD_LIBRARY_PATH="${PREFIX}/lib"
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
    export C_INCLUDE_PATH="${PREFIX}/include"
    export CPLUS_INCLUDE_PATH="${PREFIX}/include"

    cd ./pkg-config-${PKG_VER}
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../msgpack-${MSG_VER}
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../glog-${GLOG_VER}
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../ux-${UX_VER}
    ./waf configure --prefix=${PREFIX} && ./waf build && ./waf install
    check_result $?

    cd ../mecab-${MECAB_VER}
    ./configure --prefix=${PREFIX} --enable-utf8-only && make && make install
    check_result $?

    cd ../mecab-ipadic-${IPADIC_VER}
    MECAB_CONFIG="$PREFIX/bin/mecab-config"
    MECAB_DICDIR=`$MECAB_CONFIG --dicdir`
    ./configure --prefix=${PREFIX} --with-mecab-config=$MECAB_CONFIG --with-dicdir=$MECAB_DICDIR/ipadic --with-charset=utf-8 && make && make install
    check_result $?

    if [ "${USE_RE2}" == "TRUE" ]; then
      cd ../re2
      sed -i -e "s|/usr/local|${PREFIX}/|g" Makefile
      make && make install
      check_result $?
    else
      cd ../onig-${ONIG_VER}
      ./configure --prefix=${PREFIX} && make && make install
      check_result $?
    fi

    cd ../zookeeper-${ZK_VER}/src/c
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../../../jubatus_mpio-${JUBATUS_MPIO_VER}
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../jubatus_msgpack-rpc-${JUBATUS_MSGPACK_RPC_VER}
    ./configure --prefix=${PREFIX} && make && make install
    check_result $?

    cd ../jubatus-${JUBATUS_VER}
    if [ "${USE_RE2}" == "TRUE" ]; then
      ./waf configure --prefix=${PREFIX} --enable-ux --enable-mecab --enable-re2 --enable-zookeeper
    else
      ./waf configure --prefix=${PREFIX} --enable-ux --enable-mecab --enable-zookeeper
    fi
    check_result $?
    ./waf build --checkall && ./waf install
    check_result $?

    cat > ${PREFIX}/share/jubatus/jubatus.profile <<EOF
# THIS FILE IS AUTOMATICALLY GENERATED

JUBATUS_HOME=${PREFIX}
export JUBATUS_HOME

PATH=\$JUBATUS_HOME/bin:\$PATH
export PATH

CPLUS_INCLUDE_PATH=\$JUBATUS_HOME/include
export CPLUS_INCLUDE_PATH

LDFLAGS=-L\$JUBATUS_HOME/lib
export LDFLAGS

LD_LIBRARY_PATH=\$JUBATUS_HOME/lib
export LD_LIBRARY_PATH

DYLD_LIBRARY_PATH=\$JUBATUS_HOME/lib
export DYLD_LIBRARY_PATH=\$JUBATUS_HOME/lib

PKG_CONFIG_PATH=\$JUBATUS_HOME/lib/pkgconfig
export PKG_CONFIG_PATH
EOF

fi

) 2>&1 | tee $INSTALL_LOG

# to avoid getting the exit status of "tee" command
status=${PIPESTATUS[0]}

if [ "$status" -ne 0 ]; then
  echo "all messages above are saved in \"$INSTALL_LOG\""
  exit $status
fi
