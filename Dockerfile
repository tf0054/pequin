FROM ubuntu

RUN apt-get update -y

RUN apt-get install -y python2.7 libpython2.7 libpython2.7-dev golang \
          build-essential gcc g++ gcc-multilib g++-multilib ant \
          ant-optional make time libboost-all-dev libgmp10 libgmp-dev \
          zlib1g zlib1g-dev libssl-dev openjdk-8-jdk git

RUN mkdir /zkp
COPY . /zkp

WORKDIR /zkp/thirdparty
RUN /zkp/thirdparty/install_pepper_deps.sh

#WORKDIR /zkp/pepper
#CMD ["/zkp/pepper/setup.sh", "proof_of_balance"]

# Clean
RUN apt-get install -y openssh-server sudo vim
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ssh
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd && chmod 755 /var/run/sshd
ADD id_rsa.pub /root/.ssh/authorized_keys
RUN chmod -R g-rwx,o-rwx /root/.ssh

# Add a normal user
RUN useradd -p tcuser -G sudo -s /bin/bash -d /work/tf0054 tf0054
RUN ln -s /work/tf0054 /home/tf0054
# modify sudoers
# Enable passwordless sudo for users under the "sudo" group 
RUN sed -i.bkp -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
        /etc/sudoers
# Exec
EXPOSE 22
ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]
