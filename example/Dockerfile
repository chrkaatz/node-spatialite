FROM chrkaatz/node-spatialite:node-10

RUN mkdir -p /usr/src/app

COPY . /usr/src/app/
WORKDIR /usr/src/app

RUN npm install

CMD node index.js