FROM alpine as build

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge-testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
  apk --no-cache --update upgrade musl && \
  apk add --upgrade apk-tools@edge && \
  apk add --update wget curl gcc g++ make automake libtool autoconf minizip-dev "musl-utils@edge" "musl-dev@edge" "fossil@edge-testing" git libc-dev sqlite-dev zlib-dev libxml2-dev "proj-dev@edge" "geos-dev@edge-testing" "gdal-dev@edge-testing" "gdal@edge-testing" expat-dev readline-dev ncurses-dev readline ncurses-static "libc-utils@edge" "libc6-compat@edge" && \
  rm -rf /var/cache/apk/*

ENV USER me

RUN fossil clone https://www.gaia-gis.it/fossil/freexl freexl.fossil && mkdir freexl && cd freexl && fossil open ../freexl.fossil && ./configure --build=unknown-unknown-linux && make -j8 && make install

RUN git clone "https://git.osgeo.org/gitea/rttopo/librttopo.git" && cd librttopo && ./autogen.sh && ./configure && make -j8 && make install

RUN git clone "https://github.com/libgeos/geos.git" && cd geos && ./autogen.sh && ./configure && make -j8 && make install

RUN curl -s http://www.gaia-gis.it/gaia-sins/libspatialite-5.0.0.zip --output libspatialite.zip && unzip libspatialite.zip && cd libspatialite-5.0.0 && ./configure --build=unknown-unknown-linux && make -j8 && make install

RUN cp /usr/local/bin/* /usr/bin/
RUN cp -R /usr/local/lib/* /usr/lib/

# Create a minimal instance
FROM node:17-alpine3.12

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge-testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
  apk --no-cache --update upgrade musl && \
  apk add --upgrade apk-tools@edge && \
  apk add --update wget curl gcc g++ make automake libtool autoconf "fossil@edge-testing" git libc-dev sqlite-dev zlib-dev minizip-dev libxml2-dev proj "geos-dev@edge-testing" "gdal-dev@edge-testing" "gdal@edge-testing" "musl-utils@edge" "musl-dev@edge" expat-dev readline-dev ncurses-dev readline ncurses-static "libc-utils@edge" "libc6-compat@edge" && \
  rm -rf /var/cache/apk/*

# copy libs (maintaining symlinks)
COPY --from=build /usr/local/lib/ /usr/local/lib

# remove broken symlinks
RUN find -L /usr/lib -maxdepth 1 -type l -delete && \
  find /usr/lib -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \; && \
  mkdir -p /usr/src/app