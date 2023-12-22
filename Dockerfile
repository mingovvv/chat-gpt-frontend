FROM node:20

WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

RUN npm install
RUN npm build

RUN yarn install
COPY . .
RUN yarn run build

CMD ["npm", "run", "serve"]