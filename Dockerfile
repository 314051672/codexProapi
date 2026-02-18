FROM node:20-alpine

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/314051672/codexProapi.git . \
  && npm install

ENV PORT=1455
ENV HOST=0.0.0.0

EXPOSE 1455

CMD ["npm", "run", "start"]
