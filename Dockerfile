# This is a Dockerfile to be used with OpenShift3

FROM centos:7

MAINTAINER BonnierNews <devops@bonniernews.se>
# based on the work of Takayoshi Kimura <tkimura@redhat.com> and Christoph Görn <goern@b4mad.net>

ENV container docker
ENV MATTERMOST_VERSION 3.7.3
ENV MATTERMOST_VERSION_SHORT 373

USER root
# Labels consumed by Red Hat build service
LABEL Component="mattermost" \
      Name="centos/mattermost-${MATTERMOST_VERSION_SHORT}-centos7" \
      Version="${MATTERMOST_VERSION}" \
      Release="1"

# Labels could be consumed by OpenShift
LABEL io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost {$MATTERMOST_VERSION}" \
      io.openshift.expose-services="8065:mattermost" \
      io.openshift.tags="mattermost,slack"

RUN yum update -y --setopt=tsflags=nodocs && \
    yum install -y --setopt=tsflags=nodocs tar && \
    yum clean all


RUN cd /opt && \
    curl -LO https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    tar xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    rm -f /opt/mattermost/config/config.json && \
    useradd -u 1001 -r -g 0 -d /opt/mattermost -s /sbin/nologin \
        -c "Default Application User" default && \
    chown -R 1001:0 /opt/mattermost


ADD mattermost/entrypoint.sh /opt/mattermost/bin/entrypoint.sh
ADD mattermost/config.json /tmp/config.json
RUN chown 1001 /tmp/config.json && \
    mkdir -p /opt/mattermost/storage/data/opt/mattermost/storage/config && \
    chown -R 1001 /opt/mattermost/logs/ /opt/mattermost/storage

USER 1001
VOLUME /opt/mattermost/storage
EXPOSE 8065

WORKDIR /opt/mattermost/bin
ENTRYPOINT ["/opt/mattermost/bin/entrypoint.sh"]
CMD [ "./platform" ]
