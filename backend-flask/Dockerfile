# Stage 1: Build and install dependencies
FROM python:3.12.0a5-slim AS builder
WORKDIR /backend-flask
COPY requirements.txt requirements.txt
RUN pip3 install --user --no-cache-dir -r requirements.txt \
     && rm -rf /root/.cache/pip/* # clean up after the step

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
