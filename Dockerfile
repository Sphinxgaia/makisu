FROM golang:1.12.6 AS builder

ENV version=0.1.11

RUN mkdir -p /workspace/github.com/uber/makisu
WORKDIR /workspace/github.com/uber/makisu

ADD https://github.com/uber/makisu/archive/v0.1.11.tar.gz /tmp/makisu/
RUN cd /tmp/makisu/ && tar -xvf v0.1.11.tar.gz

RUN mv /tmp/makisu/makisu-${version}/Makefile /workspace/github.com/uber/makisu/ \
    &&  mv /tmp/makisu/makisu-${version}/go.mod /workspace/github.com/uber/makisu/go.mod \
    &&  mv /tmp/makisu/makisu-${version}/go.sum /workspace/github.com/uber/makisu/go.sum \
    && make vendor

RUN mv /tmp/makisu/makisu-${version}/bin /workspace/github.com/uber/makisu/bin \
    &&  mv /tmp/makisu/makisu-${version}/.git /workspace/github.com/uber/makisu/.git \
    &&  mv /tmp/makisu/makisu-${version}/lib /workspace/github.com/uber/makisu/lib \
    && make bins

RUN mv /tmp/makisu/makisu-${version}/assets /workspace/github.com/uber/makisu/assets

FROM centos:7.6.1810

LABEL MAINTAINER="sphinxgaia"

LABEL io.kubernetes.os.name=centos io.kubernetes.name.version=7.6.1810 io.kubernetes.os.date=191011 io.kubernetes.app.name=makisu app.version=0.1.11

COPY --from=builder --chown=makisu:makisu /workspace/github.com/uber/makisu/bin/makisu/makisu /makisu-internal/makisu
COPY --from=builder --chown=makisu:makisu /workspace/github.com/uber/makisu/assets/cacerts.pem /makisu-internal/certs/cacerts.pem

ENTRYPOINT ["/makisu-internal/makisu"]