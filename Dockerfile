ARG GIT_IMAGE=bitnami/git:2.35.2
ARG MAVEN_IMAGE=maven:3.8.5-openjdk-17
ARG RELEASE=0.3.2
ARG GIT_REF=develop

## Attempting to make this as compatible with Iron Bank as possible
## Matching current version on Iron Bank
FROM ${GIT_IMAGE} AS fetcher
ARG RELEASE
ARG GIT_REF
RUN git clone --recurse-submodules -b ${GIT_REF} https://github.com/usnistgov/oscal-cli.git  /usr/src/oscal-cli/

## Matching current version on Iron Bank
FROM ${MAVEN_IMAGE} AS builder
COPY --from=fetcher /usr/src/oscal-cli/ /usr/src/oscal-cli/
WORKDIR /usr/src/oscal-cli/
RUN mvn install

FROM ${MAVEN_IMAGE}
ARG RELEASE
COPY --from=builder /usr/src/oscal-cli/cli-core/target/cli-core-${RELEASE}-oscal-cli/lib/* /usr/local/lib/oscal-cli/
COPY --from=builder /usr/src/oscal-cli/cli-core/target/cli-core-${RELEASE}-oscal-cli/bin/oscal-cli /usr/local/bin/oscal-cli
ENV CLASSPATH="/usr/lib/oscal-cli/*"

VOLUME [ "/app" ]
WORKDIR /app
ENTRYPOINT ["java", \
    "-Dsun.stdout.encoding=UTF-8", \
    "-Dsun.stderr.encoding=UTF-8", \
    "-Dapp.name='oscal-cli'", \
    "-Dapp.home='/usr/local/lib/oscal-cli/'",\
    "gov.nist.secauto.oscal.tools.cli.core.CLI"]
