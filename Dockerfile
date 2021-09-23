FROM centos:centos8
RUN yum -y install epel-release
RUN yum -y install java-11-openjdk-headless.x86_64 java-latest-openjdk-headless-fastdebug.x86_64 \
                   emacs-nox perl perl-Getopt-Long perl-App-cpanminus.noarch pkgconf-pkg-config.x86_64 \
		   openssl nmap-ncat
###
### Install Confluent Packages.
### Version (5.4) must match version referenced in confluent.repo
###
RUN rpm --import https://packages.confluent.io/rpm/6.1/archive.key
ADD etc/repos/confluent.repo /etc/yum.repos.d/confluent.repo
RUN  yum  --enablerepo=powertools install snappy-devel perl-Test-Most
RUN yum -y install boost-devel boost snappy.x86_64 openssl-devel.x86_64 cyrus-sasl-md5.x86_64 cyrus-sasl-devel.x86_64
RUN yum -y install jansson.x86_64
RUN yum -y install --disablerepo=* --enablerepo=Confluent --enablerepo=Confluent.dist confluent-community-2.13 \
                   avro-c.x86_64 avro-c-devel.x86_64 avro-c-debuginfo.x86_64 avro-c-tools.x86_64 \
                   avro-cpp.x86_64 avro-cpp-devel.x86_64 avro-cpp-debuginfo.x86_64 \
                   confluent-libserdes.x86_64 confluent-libserdes-devel.x86_64 confluent-libserdes-debuginfo.x86_64 \
		   confluent-cli.x86_64 confluent-kafka confluent-common.noarch \
                   librdkafka1.x86_64 librdkafka-devel.x86_64 librdkafka1-debuginfo.x86_64
RUN yum -y install git gcc make
RUN cpanm install Net::Kafka
###
### Install kafkacat
###
RUN cd /usr/local/src && \
    git clone https://github.com/edenhill/kafkacat.git && \
    cd kafkacat && ./configure --prefix=/usr/local && make && make install
RUN yum -y install python3-devel.x86_64 python3-pip.noarch
