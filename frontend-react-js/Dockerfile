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
