FROM chrkaatz/node-spatialite:lts

RUN mkdir -p /usr/src/app

COPY . /usr/src/app/
WORKDIR /usr/src/app

RUN npm install

CMD node index.js