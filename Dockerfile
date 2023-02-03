## Attempting to make this as compatible with Iron Bank as possible
## Matching current version on Iron Bank
FROM bitnami/git:2.35.2 AS fetcher
ARG RELEASE=0.3.0
RUN git clone --recurse-submodules -b v${RELEASE} https://github.com/usnistgov/oscal-cli.git  /usr/src/oscal-cli/

## Matching current version on Iron Bank
FROM maven:3.8.5-openjdk-17 AS builder
COPY --from=fetcher /usr/src/oscal-cli/ /usr/src/oscal-cli/
WORKDIR /usr/src/oscal-cli/
RUN mvn install

FROM maven:3.8.5-openjdk-17
ARG RELEASE=0.3.0
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
