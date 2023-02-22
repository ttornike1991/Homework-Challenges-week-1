Homework-Challenges-week-1
Containerization

# 1 Run the dockerfile CMD as an external script
We have to make forexample **start.sh** into folder where is docker file: **This is for Backend-flask**

**start.sh content:**
```
#!/bin/bash

python3 -m flask run --host=0.0.0.0 --port=4567

chmod +x start.sh
```
**Dockerfile content:**
```
FROM python:3.12.0a5-slim

# Inside Container
# make a new folder inside container
WORKDIR /backend-flask

# Outside Container -> Inside Container
# this contains the libraries want to install to run the app
COPY requirements.txt requirements.txt

# Inside Container
# Install the python libraries used for the app
RUN pip3 install -r requirements.txt

# Outside Container -> Inside Container
# . means everything in the current directory
# first period . - /backend-flask (outside container)
# second period . /backend-flask (inside container)
COPY . .

# Set Enviroment Variables (Env Vars)
# Inside Container and wil remain set when the container is running
ENV FLASK_ENV=development

EXPOSE ${PORT}

#Use external script start.sh

ENTRYPOINT ["/bin/bash", "./start.sh"]
```
We have to make forexample **npmi.sh** into folder where is docker file: This is for **frontend-react-js**

**npmi.sh content:**

```
#!/bin/bash

npm start

chmod +x npmi.sh

```


**Dockerfile content:**


```
FROM node:19.6.0-bullseye-slim

ENV PORT=3000

COPY . /frontend-react-js
WORKDIR /frontend-react-js
RUN npm install
EXPOSE ${PORT}
ENTRYPOINT ["/bin/bash", "./npmi.sh"]
```

# 2 Push and tag a image to DockerHub

**Check images:**
```
Docker images
```
**Tag images:**
```
docker tag homework-challenges-week-1-docker-conteinerization-full-guide-frontend-react-js:latest ttornike1991/frontend:1.1
docker tag homework-challenges-week-1-docker-conteinerization-full-guide-backend-flask:latest ttornike1991/backend:1.0
docker tag postgres:13-alpine ttornike1991/postgres:1.1
docker tag amazon/dynamodb-local:latest ttornike1991/dynamodb:1.1
```

**Push images:**
```
docker push ttornike1991/backend:1.0
docker push ttornike1991/frontend:1.1
docker push ttornike1991/dynamodb:1.1
docker push ttornike1991/postgres:1.1
```


# 3 Use multi-stage building for a Dockerfile build


**For backend use non root-user**
```
# Stage 1: Build and install dependencies
FROM python:3.12.0a5-slim AS builder
WORKDIR /backend-flask
COPY requirements.txt requirements.txt
RUN pip3 install --user --no-cache-dir -r requirements.txt

# Stage 2: Copy dependencies and source code
FROM python:3.12.0a5-slim
WORKDIR /backend-flask
COPY --from=builder /root/.local /usr/local
COPY . .

# Set environment variables
ENV FLASK_ENV=development
EXPOSE ${PORT}

# Create a new user and switch to that user
RUN groupadd -r myapp && useradd --no-log-init -r -g myapp myapp
RUN chown -R myapp:myapp /backend-flask
USER myapp

# Use external script start.sh
ENTRYPOINT ["/bin/bash", "./start.sh"]
```

**For frontend**

```
# Build stage
FROM node:19.6.0-bullseye-slim AS build
WORKDIR /frontend-react-js
COPY . /frontend-react-js
RUN npm install && npm run build

# Production stage
FROM node:19.6.0-bullseye-slim
ENV PORT=3000
WORKDIR /frontend-react-js
COPY --from=build /frontend-react-js/build /frontend-react-js
EXPOSE ${PORT}
ENTRYPOINT ["/bin/bash", "./npmi.sh"]
```
