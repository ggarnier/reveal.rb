FROM ruby:2.5-alpine
MAINTAINER Guilherme Garnier <guilherme.garnier@gmail.com>

RUN apk update && apk add git make gcc libc-dev
