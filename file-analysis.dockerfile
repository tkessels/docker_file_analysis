FROM kalilinux/kali-rolling
LABEL maintainer="tabledevil"

USER root
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y \
  autoconf \
  catdoc \
  docx2txt \
  exiftool \
  git \
  imagemagick \
  libboost-python-dev \
  libboost-thread-dev \
  libreoffice \
  libssl-dev \
  libtool \
  mc \
  mpack \
  osslsigncode \
  p7zip-full \
  pdftk \
  pev \
  pkg-config \
  python \
  python3 \
  python3-lxml \
  python3-pip \
  ruby \
  unoconv \
  unzip \
  wget \
  ; \
  rm -rf /var/lib/apt/lists/*

# Removed packages
# python-pil
# language-pack-de \

RUN git clone https://github.com/jesparza/peepdf /opt/peepdf
RUN git clone https://github.com/DidierStevens/DidierStevensSuite /opt/didierstevenssuite

RUN pip3 install --upgrade pip
RUN pip3 install psutil unotools oletools

#RUN python -m pip install -U https://github.com/decalage2/oletools/archive/master.zip
RUN gem install origami
#RUN yes | pip uninstall pyparsing ; pip install pyparsing==2.3.0
RUN chmod +x /opt/didierstevenssuite/*py

RUN sed -i '/PDF/s/"none"/"read|write"/' /etc/ImageMagick-6/policy.xml

ENV PATH="${PATH}:/opt/peepdf/:/opt/didierstevenssuite/"
ADD files/README /opt/README
ADD files/command_help /opt/command_help
RUN echo 'cat /opt/README' >> /etc/bash.bashrc

###  VIPERMONKEY
## install pypy
RUN wget -O-  https://downloads.python.org/pypy/pypy2.7-v7.3.5-linux64.tar.bz2 | tar -C /opt/ -xvj
RUN ln -s /opt/pypy2.7-v7.3.5-linux64/bin/pypy /usr/local/bin/pypy
## install and upgrade pip
RUN pypy -m ensurepip
RUN pypy -m pip install -U pip
RUN pypy -m pip install -U https://github.com/decalage2/ViperMonkey/archive/master.zip
RUN ln -s /opt/pypy2.7-v7.3.5-linux64/site-packages/vipermonkey/vmonkey.py /usr/local/bin/vmonkey
RUN chmod +x /usr/local/bin/vmonkey
### LATER
#RUN git clone https://github.com/buffer/pyv8.git ; cd pyv8 ; python setup.py build && python setup.py install && cd .. && rm -rf pyv8
#RUN git clone https://github.com/buffer/libemu.git ; cd libemu ; autoreconf -v -i && ./configure --prefix=/opt/libemu && make install && cd .. && rm -rf libemu2


RUN groupadd -g 1000 -r user && \
useradd -u 1000 -r -g user -d /home/user -s /sbin/nologin -c "Nonroot User" user && \
mkdir /home/user && \
cp /root/.bashrc /home/user/ && \
chown -R user:user /home/user


RUN groupadd -g 1001 -r nonroot && \
useradd -u 1001 -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
mkdir /home/nonroot && \
cp /root/.bashrc /home/nonroot/ && \
chown -R nonroot:nonroot /home/nonroot


ENV LANG de_DE.UTF-8
USER nonroot
WORKDIR /data
CMD /bin/bash
