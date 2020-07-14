FROM node:12-alpine
WORKDIR /docker-app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]