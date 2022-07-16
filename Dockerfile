# Step 1: Build Angular frontend
FROM node:16-alpine3.15 as ANGULAR_BUILD
RUN apk update
COPY ./angular-frontend /usr/angular-frontend
WORKDIR /usr/angular-frontend
RUN npm config delete proxy
RUN npm config delete https-proxy
RUN npm install -g npm@latest
RUN npm config set fetch-retry-mintimeout 20000
RUN npm config set fetch-retry-maxtimeout 120000
RUN npm install -g @angular/cli@13.3.7
RUN npm install
RUN ng build

# Step 2: Compile and build Go code to binary
# FROM golang:1.18-alpine3.16 as GO_BUILD
# COPY go-backend /go-backend
# WORKDIR /go-backend
# RUN go mod download
# RUN go build -o ./server

# Step 3: Combine Angular-frontend && Go-backend
FROM nginx:alpine
RUN apk update
WORKDIR /usr/share/nginx/html
COPY --from=ANGULAR_BUILD /usr/angular-frontend/dist/todolists ./
# COPY --from=GO_BUILD ./go-backend/server ./
COPY nginx.conf /etc/nginx/nginx.conf
COPY commands.sh ./
ENTRYPOINT [ "/bin/sh", "./commands.sh" ]
