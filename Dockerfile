FROM rockylinux:8.5
RUN dnf -y install epel-release
RUN dnf -y install --enablerepo=powertools java-11-openjdk-headless.x86_64 java-latest-openjdk-headless-fastdebug.x86_64 \
                   emacs-nox perl perl-Getopt-Long perl-App-cpanminus perl-Test-Most perl-JSON pkgconf-pkg-config.x86_64 \
                   openssl nmap-ncat git gcc make snappy snappy-devel boost-devel boost openssl-devel \
                   cyrus-sasl-md5 cyrus-sasl-devel jansson python3-devel python39-devel.x86_64 python3-pip.noarch \
                   python39-toml python3-toml net-tools bind-utils libcurl-devel curl jansson-devel jansson
###
### Install Confluent Packages.
### Version (5.4) must match version referenced in confluent.repo
###
RUN dnf -y upgrade --refresh rpm glibc
RUN rm /var/lib/rpm/.rpm.lock
RUN dnf -y upgrade dnf
RUN rpm --import https://packages.confluent.io/rpm/7.3/archive.key
ADD etc/repos/confluent.repo /etc/yum.repos.d/confluent.repo
RUN dnf -y install --disablerepo=* --enablerepo=Confluent --enablerepo=Confluent.dist confluent-community-2.13 \
                   avro-c.x86_64 avro-c-devel.x86_64 avro-c-debuginfo.x86_64 avro-c-tools.x86_64 \
                   avro-cpp.x86_64 avro-cpp-devel.x86_64 avro-cpp-debuginfo.x86_64 \
                   confluent-libserdes.x86_64 confluent-libserdes-devel.x86_64 confluent-libserdes-debuginfo.x86_64 \
                   confluent-cli.x86_64 confluent-kafka confluent-common.noarch \
                   librdkafka1.x86_64 librdkafka-devel.x86_64 librdkafka1-debuginfo.x86_64
RUN cpanm install Net::Kafka && rm -rf /root/.cpanm
###
### Install kafkacat
###
RUN cd /usr/local/src && \
    git clone https://github.com/edenhill/kcat.git && \
    cd kcat && ./configure --prefix=/usr/local && make && make install
