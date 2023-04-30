FROM node:lts-alpine
WORKDIR /usr/app
COPY package*.json ./
RUN npm install
COPY src/ .
ENV HOST 0.0.0.0
ENV PORT 8080
EXPOSE 8080
RUN  addgroup -S app && adduser -S app -G app
USER app
HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1
ENTRYPOINT ["node", "/usr/app/app.js"]