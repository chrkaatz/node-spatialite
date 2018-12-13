FROM alpine as build

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge-testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
  apk --no-cache --update upgrade musl && \
  apk add --upgrade apk-tools@edge && \
  apk add --update wget curl gcc g++ make automake libtool autoconf fossil git libc-dev sqlite-dev zlib-dev libxml2-dev "proj4-dev@edge-testing" "geos-dev@edge-testing" "gdal-dev@edge-testing" "gdal@edge-testing" expat-dev readline-dev ncurses-dev readline ncurses-static libc6-compat && \
  rm -rf /var/cache/apk/*

ENV USER me

RUN fossil clone https://www.gaia-gis.it/fossil/freexl freexl.fossil && mkdir freexl && cd freexl && fossil open ../freexl.fossil && ./configure && make -j8 && make install

RUN git clone "https://git.osgeo.org/gitea/rttopo/librttopo.git" && cd librttopo && ./autogen.sh && ./configure && make -j8 && make install

RUN git clone "https://github.com/libgeos/geos.git" && cd geos && ./autogen.sh && ./configure && make -j8 && make install

RUN curl -s http://www.gaia-gis.it/gaia-sins/libspatialite-4.3.0a.zip --output libspatialite.zip && unzip libspatialite.zip && cd libspatialite-4.3.0a && ./configure && make -j8 && make install

RUN cp /usr/local/bin/* /usr/bin/
RUN cp -R /usr/local/lib/* /usr/lib/

# Create a minimal instance
FROM node:11-alpine

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "@edge-testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && \
  apk --no-cache --update upgrade musl && \
  apk add --upgrade apk-tools@edge && \
  apk add --update wget curl gcc g++ make automake libtool autoconf fossil git libc-dev sqlite-dev zlib-dev libxml2-dev "proj4-dev@edge-testing" "geos-dev@edge-testing" "gdal-dev@edge-testing" "gdal@edge-testing" expat-dev readline-dev ncurses-dev readline ncurses-static libc6-compat && \
  rm -rf /var/cache/apk/*

# copy libs (maintaining symlinks)
COPY --from=build /usr/local/lib/ /usr/local/lib

# remove broken symlinks
RUN find -L /usr/lib -maxdepth 1 -type l -delete && \
    find /usr/lib -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \; && \
    mkdir -p /usr/src/app