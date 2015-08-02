FROM ubuntu:14.04

MAINTAINER "Christian Berg" berg.christian@gmail.com

RUN echo "deb http://mirrors.softliste.de/cran/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev r-base r-base-dev

ADD src src
RUN R --vanilla < src/dependencies.r
