FROM centos:7
RUN yum  update -y
RUN yum install -y epel-release openssh-clients make munge munge-devel gcc gcc-c++ perl sudo perl-CPAN mysql-devel
RUN yum install -y perl-XML-Parser perl-Test-Simple perl-GD perl-XML-Parser perl-XML-Simple perl-XML-SAX build-essential git curl ncurses-devel zlib-devel libzstd-devel subversion unzip gd-devel snappy-devel lz4-devel
RUN yum install -y wget mysql gcc cpan perl-Time-HiRes perl-Archive-Tar vim-minimal perl-Archive-Zip java-1.7.0-openjdk-devel cmake glibc.i686 perl-DBD-SQLite perl-DBD-MySQL perl-LMDB_File perl-Time-Piece perl-List-Compare perl-File-HomeDir perl-File-Which bzip2 tar htop 
RUN yum install -y which make munge munge- bzip2 vim-minimal openssh-clients python-pip python-devel python-setuptools lmdb-devel bzip2-devel xz-devel mod-ssl curl-devel libcurl pigz mod_ssl
RUN yum group install -y "Development Tools"
RUN yum install -y "perl(XML::LibXML)"


RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - http://pi.dk/3) | bash
RUN curl -L http://cpanmin.us | perl - --self-upgrade


RUN mkdir /software

ADD ./cpanfile /software/cpanfile

RUN cd /software/;cpanm --installdeps . 

ADD ./tar/kyotocabinet-perl-1.20.tar.gz /software/
ADD ./tar/samtools-0.1.19.tar.bz2 /software/
ADD ./tar/samtools-1.2.tar.bz2 /software/
ADD ./tar/tabix-0.2.6.tar.bz2 /software/
ADD ./tar/kyotocabinet-1.2.76.tar.gz /software/kyotocabinet
ADD ./tar/vcftools_0.1.12b.tar.gz /software/
ADD ./tar/freebayes.tar.gz /software/

#RUN cd /software/kyotocabinet-1.2.76;./configure;make;make install;cd /software/kyotocabinet-perl-1.20;perl Makefile.PL;make;make install 

#SAMTOOLS
ENV SAMTOOLS /software/samtools-0.1.19/
RUN  cd /software/samtools-0.1.19/;sed -i '/-g -Wall -O2/c\CFLAGS   = -g -Wall -O2 -fPIC ' Makefile;cp bam2depth.c bam2depth.ori;  cat  bam2depth.ori | perl -lane '$a=$_;print $a; print qq{ bam_mplp_set_maxcnt(mplp,1000000); \n} if $a =~/mplp \= bam_mplp_init\(n/;' > bam2depth.c;make;
ADD ./tar/samtools-1.10.tar.bz2 /software/
RUN cd /software/samtools-1.10/;cp bam2depth.c bam2depth.ori;  cat  bam2depth.ori |  perl -lane '$a=$_;if ($a =~/bam_mplp_set_maxcnt/){print "bam_mplp_set_maxcnt(mplp,1000000); \n"} else {print $a}' > bam2depth.c;make;make prefix=/usr/local install;
RUN cd /software/tabix-0.2.6/;make &&  cd /software/tabix-0.2.6/perl;perl Makefile.PL;make;make install && cd /software/vcftools_0.1.12b/;make;cp -r /software/vcftools_0.1.12b/bin/* /usr/local/bin/ &&  sed -i '/use warnings;/c\#use warnings; ' /usr/local/lib64/perl5/Tabix.pm &&  cp /software/tabix-0.2.6/bgzip /usr/local/bin;cp /software/tabix-0.2.6/tabix /usr/local/bin
RUN cpanm Alien::Libxml2
RUN cpanm -n Bio::DB::Sam 
RUN cpanm --notest Proc::Daemon && cpanm Storable &&  cpanm  install http://cpan.metacpan.org/authors/id/I/IS/ISHIGAKI/DBD-SQLite-1.51_04.tar.gz &&  cpanm  Want --verbose &&  cpanm  IO::Prompt --force && cpanm -n Date::Tiny 

RUN cpanm install -n GO::Utils
RUN   yes "\n" |  cpanm GO::AppHandle --verbose -n 

ADD ./tar/Statistics-Zscore-0.00002.tar.gz /software/
RUN sh -c ' printf "\n/usr/local/lib" >> /etc/ld.so.conf';ldconfig &&  cd /software/Statistics-Zscore-0.00002/;perl Makefile.PL;make;make install
RUN cd /etc/;chmod u+w sudoers;cp sudoers sudoers.ori;cat sudoers.ori | perl -lane '$a=$_;$a.=":/usr/local/bin" if $a =~ /secure_path/; $a.="\npolyweb\tALL=(ALL)\tALL"if $a =~/^root/;print $a'>sudoers;chmod u-w sudoers
ADD ./httpd.conf /etc/httpd/conf/

#GATK
RUN mkdir /software/gatk/;chmod a+rx /software/gatk; 
ADD ./tar/GenomeAnalysisTK-3.4-46.tar.bz2 /software/gatk
ADD ./tar/picard-tools-1.136.tar.gz /software/


ADD ./tar/bwa-0.7.17.tar.bz2 /software/
RUN cd /software/; git clone https://github.com/lh3/bwa.git;cd bwa; make;cp bwa /usr/local/bin/;
#RUN cd /software/bwa-0.7.17;make;cp bwa /usr/local/bin/ && cd /software/;
#RUN git clone --branch=develop git://github.com/samtools/htslib.git && cd htslib &&  git submodule update --init --recursive && autoreconf -i && ./configure && make && make install
RUN git clone --branch=develop https://github.com/samtools/htslib.git && cd htslib && git submodule update --init --recursive && autoreconf -i && ./configure && make && make install



RUN cd /software/;git clone --branch=develop git://github.com/samtools/bcftools.git;cd bcftools; make;make install && cd /software/;git clone --recursive https://github.com/noporpoise/seq-align;cd seq-align;make

ADD ./tar/sqlite3 /usr/bin/

RUN rpm -Uvh http://repo.openfusion.net/centos7-x86_64/openfusion-release-0.7-1.of.el7.noarch.rpm 
RUN yum install -y  httpd
#RUN cd /usr/share/httpd;mv icons icons.old;ln -s /poly-disk/www/icons/ icons
RUN  mkdir /software/bds
ADD ./tar/bds_Linux.tgz /software/bds/
RUN  cd /software/bds  && ln -s /software/bds/.bds/bds /usr/local/bin/bds



RUN ls -d //software/samt*
ADD ./tar/sambamba.tar.gz /software/




ADD ./tar/vcflib.tar.gz /software/
RUN cd /software/vcflib/;make clean;make

##########
# JAVA 
##########
ADD ./tar/jdk-8u131-linux-x64.rpm /software/
RUN rpm -ivh /software/jdk-8u131-linux-x64.rpm && rm /software/jdk-8u131-linux-x64.rpm
RUN  alternatives --list | perl -lane '@t =split(" ",$_);if ($t[0] eq "java" ){system "alternatives --remove java ".$t[2]}'

##########
#install htslib

RUN yum install -y curl-devel libcurl;git clone git://github.com/samtools/htslib.git;cd htslib;autoheader && autoconf && ./configure;make;


RUN echo 'export C_INCLUDE_PATH=/usr/local/include' >> /etc/bashrc && echo 'export LIBRARY_PATH=/usr/local/lib' >> /etc/bashrc &&  echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> /etc/bashrc && echo 'export TERM=xterm' >> /etc/bashrc

###########################################################################
## INSTALL SOFTWARE
#############################################@

ADD ./tar/Align-NW-1.01.tar.gz /software/
RUN  cd /software/Align-NW-1.01;make clean;perl Makefile.PL ;make;make install
RUN cp  /usr/local/lib64/perl5/LMDB_File.pm  /usr/local/lib64/perl5/LMDB_File.pm.backup && chmod a+w /usr/local/lib64/perl5/LMDB_File.pm && cat /usr/local/lib64/perl5/LMDB_File.pm.backup | perl -lane 'if ($_=~ /OOPS/) {print "# ".$_ } else {print $_}'> /usr/local/lib64/perl5/LMDB_File.pm && chmod a-w /usr/local/lib64/perl5/LMDB_File.pm
RUN mkdir /software/bin/ && ln -s /usr/local/bin/tabix /software/bin/tabix && ln -s /usr/local/bin/bcftools /software/bin/bcftools && ln -s /usr/local/bin/samtools /software/bin/samtools && ln -s /usr/local/bin/bgzip /software/bin/bgzip && ln -s /software/sambamba/sambamba /software/bin/sambamba
ADD ./tar/plink.tar.gz /software/
RUN ln -s   /software/plink-1.07-x86_64/plink /software/bin/plink && ln -s /software/seq-align/bin/needleman_wunsch /software/bin/needleman_wunsch 
RUN rm -rf /root/.cpan/*
RUN cpanm -n  Algorithm::Combinatorics
RUN cpan install BENBOOTH/Set-IntervalTree-0.10.tar.gz
RUN cpanm  CGI::Session
RUN  cd /software && git clone https://github.com/hoytech/vmtouch.git && cd vmtouch && make && sudo make install
ADD ./tar/elprep-v4.1.5.tar.gz /software/bin/
RUN  cd /software && wget https://github.com/samtools/htslib/releases/download/1.16/htslib-1.16.tar.bz2 && tar -xvf  htslib-1.16.tar.bz2 &&  cd /software/htslib-1.16/  && ./configure && make && export HTSLIB_DIR=/software/htslib-1.16/ && cpan install Bio::DB::HTS 
RUN cpan install HTML::TableExtract && cpan install Compress::Zstd  && cpan -f install RocksDB

#Ajouté le 5 Mars 2024
#cpan -f install RocksDB


##########
# MORE 
##########


RUN cd /software && wget https://github.com/samtools/htslib/releases/download/1.16/htslib-1.16.tar.bz2 && tar -xvf  htslib-1.16.tar.bz2 &&  cd /software/htslib-1.16/  && ./configure && make && export HTSLIB_DIR=/software/htslib-1.16/ && cpan install Bio::DB::HTS

RUN cpan install Sereal

RUN cpan install HTML::TableExtract && cpan install Compress::Zstd

RUN cpan install Text/Xslate.pm  &&  cpan install strictures.pm

RUN yum -y install libzstd-devel libzstd liblz4hcdevel lz4-devel

RUN yum -y install snappy-devel zlib-devel bzip2-devel bzip2

RUN cpan install Compress::Zstd  && cpan -f install RocksDB

CMD ["/bin/bash"] 



#ENV POLYWEB_USER polyweb
#ENV POLYWEB_GRP polyweb
#ENV POLYWEB_GID 9999
#ENV POLYWEB_UID 9999
#RUN groupadd $POLYWEB_GRP -g $POLYWEB_GID;useradd $POLYWEB_USER -u $POLYWEB_UID -g $POLYWEB_GRP;
#RUN yum install -y passwd
#RUN pwconv
#RUN echo "polypass" | /usr/bin/passwd --stdin polyweb
#RUN pwconv
