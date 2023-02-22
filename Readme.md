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

# 4 Implement a healthcheck in the V3 Docker compose file

```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
#Healthcheck    
    healthcheck:
      test: ["CMD-SHELL", "curl --fail http://localhost:4567/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
 #Healthcheck    
    healthcheck:
      test: ["CMD-SHELL", "curl --fail http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
  dynamodb-local:
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
#Healthcheck    
    healthcheck:
      test: ["CMD-SHELL", "curl --fail http://localhost:8000/shell || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data   
#Healthcheck      
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U postgres || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

networks: 
  internal-network:
    driver: bridge
    name: cruddur
    
volumes:
  db:
    driver: local
```
