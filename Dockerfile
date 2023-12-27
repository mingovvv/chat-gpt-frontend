# for build
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# for runtime
FROM nginx:stable-alpine AS runtime
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

## for build
#FROM node:20 AS build
#WORKDIR /app
#COPY package*.json ./
#COPY yarn.lock ./
#RUN yarn install
#COPY . .
#RUN yarn run build
#
## for runtime
#FROM nginx:1.21.1-alpine AS runtime
##COPY --from=build /app/dist /usr/share/nginx/html
#COPY --from=build . /usr/share/nginx/html
#EXPOSE 8080
#CMD ["nginx", "-g", "daemon off;"]