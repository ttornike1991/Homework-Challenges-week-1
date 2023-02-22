# Build stage
FROM node:19.6.0-bullseye-slim AS build
WORKDIR /frontend-react-js
COPY . /frontend-react-js
RUN npm install --production && npm run build \
    && rm -rf /frontend-react-js/node_modules # clean up after the step

# Production stage
FROM node:19.6.0-bullseye-slim
ENV PORT=3000
WORKDIR /frontend-react-js
COPY --from=build /frontend-react-js/build /frontend-react-js
EXPOSE $PORT
ENTRYPOINT ["/bin/bash", "./npmi.sh"]
