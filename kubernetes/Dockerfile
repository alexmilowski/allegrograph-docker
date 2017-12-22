FROM ubuntu:latest
#FROM centos:centos6

MAINTAINER alex@milowski.com

ARG VERSION=6.3.0
ARG DATADIR=/data
ARG ADMIN_USER=admin
ARG ADMIN_PASSWORD=xyzzy
RUN apt-get update
RUN apt-get install -y curl bzip2

RUN groupadd agraph \
    && useradd -d /data -g agraph agraph

RUN curl -f -O http://franz.com/ftp/pri/acl/ag/ag${VERSION}/linuxamd64.64/agraph-${VERSION}-linuxamd64.64.tar.gz
RUN tar xfz agraph-${VERSION}-linuxamd64.64.tar.gz && rm -f agraph-${VERSION}-linuxamd64.64.tar.gz
RUN mkdir ${DATADIR}
RUN chown -R agraph:agraph ${DATADIR}
RUN cd agraph-${VERSION}; \
      ./install-agraph /app/agraph -- --non-interactive \
      --config-file ${DATADIR}/etc/agraph.cfg \
		--data-dir ${DATADIR} \
		--log-dir ${DATADIR}/log \
		--pid-file ${DATADIR}/var/agraph.pid \
		--runas-user agraph \
		--super-user ${ADMIN_USER} \
		--super-password ${ADMIN_PASSWORD}
RUN rm -r agraph-${VERSION}
RUN mkdir /var/local/agraph/ && chown -R agraph:agraph /var/local/agraph/
RUN cp /data/etc/agraph.cfg /var/local/agraph && cp /data/settings/user/admin /var/local/agraph

VOLUME ${DATADIR}

EXPOSE 10000-10036

COPY run-agraph.sh /
CMD ["/run-agraph.sh"]
