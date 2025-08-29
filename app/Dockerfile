FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci || npm install --omit=dev
COPY . .
EXPOSE 8080
USER 10001
CMD ["npm","start"]
#