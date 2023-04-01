# This is the latest stable Debian
FROM docker.io/debian:latest as base

FROM base as builder
RUN apt update && apt install -y build-essential librtlsdr-dev pkg-config libncurses5-dev curl

ARG DUMP1090_VERSION=v8.2
ARG DUMP1090_SRC=https://github.com/flightaware/dump1090/archive/refs/tags/v8.2.tar.gz

RUN curl -L --output 'dump1090-fa.tar.gz' "${DUMP1090_SRC}"
# sha256sum dump1090-fa.tar.gz && echo "${DUMP1090_TAR_HASH}  dump1090-fa.tar.gz" | sha256sum -c

WORKDIR /dump1090/
RUN tar -xvf ../dump1090-fa.tar.gz --strip-components=1
RUN make BLADERF=NO HACKRF=no LIMESDR=no DUMP1090_VERSION="${DUMP1090_VERSION}"
RUN make test

FROM base
RUN apt update && apt install -y rtl-sdr libncurses6
COPY --from=builder /dump1090/dump1090 /usr/local/bin/dump1090

# Raw output
EXPOSE 30002/tcp
# Beast output
EXPOSE 30005/tcp

ENTRYPOINT ["/usr/local/bin/dump1090", "--net", "--net-bind-address", "0.0.0.0", "--net-heartbeat", "10"]
