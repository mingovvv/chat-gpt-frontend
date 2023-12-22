FROM node:20

WORKDIR /app

COPY package*.json ./

RUN yarn install

COPY . .

RUN yarn run build


CMD ["npm", "run", "serve"]