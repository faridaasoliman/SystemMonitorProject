# Start from Ubuntu Linux (Docker handles Linux inside)
FROM ubuntu:22.04

# Install some basic tools for metrics collection
RUN apt update && apt install -y \
    bash \
    coreutils \
    procps \
    sysstat \
    smartmontools \
    lm-sensors \
    curl && \
    apt clean

# Copy the scripts from collector folder into the container
COPY . /app
WORKDIR /app

# Make a sample main.sh if it doesn't exist
RUN echo '#!/bin/bash' > main.sh && \
    echo 'mkdir -p /app/logs' >> main.sh && \
    echo 'echo "sample-metric: $(date)" >> /app/logs/metrics.log' >> main.sh && \
    echo 'sleep infinity' >> main.sh && \
    chmod +x main.sh

# Run the main script when container starts
CMD ["bash", "main.sh"]
