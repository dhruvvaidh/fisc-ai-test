# Build stage
FROM node:16-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install

# Build with environment variables
ARG REACT_APP_COGNITO_REGION
ARG REACT_APP_USER_POOL_ID
ARG REACT_APP_USER_POOL_WEB_CLIENT_ID

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
