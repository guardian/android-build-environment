# Android Dockerfile

FROM ubuntu:14.04

MAINTAINER Guardian Android Team "android@theguardian.com"

# Sets language to UTF8 : this works in pretty much all cases
ENV LANG en_US.UTF-8
RUN locale-gen $LANG

ENV DOCKER_ANDROID_LANG en_US
ENV DOCKER_ANDROID_DISPLAY_NAME mobileci-docker

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Updating & Installing packages
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    bzip2 \
    ca-certificates-java \
    curl \
    pkg-config \
    software-properties-common \
    unzip \
    wget \
    zip \
    --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Java
RUN apt-add-repository ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get -y install openjdk-8-jdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Environment variables
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV JENKINS_HOME $HOME
ENV PATH ${INFER_HOME}/bin:${PATH}
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Add build user account, values are set to default below
ENV RUN_USER mobileci
ENV RUN_UID 5089

RUN id $RUN_USER || adduser --uid "$RUN_UID" \
    --gecos 'Build User' \
    --shell '/bin/sh' \
    --disabled-login \
    --disabled-password "$RUN_USER"

# Install Android SDK
RUN wget -nv https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \
  && unzip sdk-tools-linux-3859397.zip \
  && mkdir $ANDROID_SDK_HOME \
  && mv tools $ANDROID_SDK_HOME/tools \
  && chown -R $RUN_USER:$RUN_USER $ANDROID_HOME \
  && chmod -R a+rx $ANDROID_HOME \
  && rm sdk-tools-linux-3859397.zip

ENV ANDROID_COMPONENTS platform-tools,android-26,build-tools-26.0.1

# Install Android tools
RUN echo y | $ANDROID_SDK_HOME/tools/bin/sdkmanager "platform-tools" "platforms;android-26" "build-tools;26.0.1" \
  && chown -R $RUN_USER:$RUN_USER $ANDROID_HOME \
  && chmod -R a+rx $ANDROID_HOME

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Creating project directories prepared for build when running
# `docker run`
ENV PROJECT /project
RUN mkdir $PROJECT
RUN chown -R $RUN_USER:$RUN_USER $PROJECT
WORKDIR $PROJECT

USER $RUN_USER
RUN echo "sdk.dir=$ANDROID_HOME" > local.properties
