FROM node:lts-alpine
WORKDIR /usr/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
RUN useradd -u 1000 app
USER app
HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
CMD ["node", "app.js"]