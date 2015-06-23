FROM debian:wheezy

MAINTAINER Roy Inganta Ginting <roy.i.ginting@gdplabs.id>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/jenkins-slave
ENV JENKINS_SWARM_VERSION 1.22
ENV ANDROID_SDK_VERSION 24.3.2
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle/
ENV ANDROID_HOME /opt/android-sdk-linux/
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH

RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | /usr/bin/debconf-set-selections && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupdteam.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    git curl wget unzip oracle-java7-installer oracle-java7-set-default \
    libncurses5:i386 libstdc++6:i386 zlib1g:i386 && \
    rm -fr /var/lib/apt/lists

RUN wget --progress=dot:giga https://dl.google.com/android/android-sdk_r$ANDROID_SDK_VERSION-linux.tgz && \
    mv android-sdk_r$ANDROID_SDK_VERSION-linux.tgz /opt/ && \
    cd /opt && tar xzvf ./android-sdk_r$ANDROID_SDK_VERSION-linux.tgz && \
    rm android-sdk_r$ANDROID_SDK_VERSION-linux.tgz

RUN echo "y" | android update sdk -u --filter android-8,\
android-10,\
android-11,\
android-12,\
android-13,\
android-14,\
android-15,\
android-16,\
android-17,\
android-18,\
android-19,\
android-20,\
android-21,\
android-22,\
extra-android-m2repository,\
extra-android-support,\
extra-google-m2repository && \
    chmod -R 755 $ANDROID_HOME

RUN echo "y" | android update sdk -u --filter tools,platform-tools,build-tools-22.0.1

ADD jenkins-slave.sh /usr/local/bin/jenkins-slave.sh
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
    chmod 755 /usr/share/jenkins && \
    useradd -c "Jenkins Slave user" -d /home/jenkins-slave -m jenkins-slave && \
    chmod +x /usr/local/bin/jenkins-slave.sh

USER jenkins-slave
VOLUME /home/jenkins-slave
ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]

