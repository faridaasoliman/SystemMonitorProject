# Start from Python (lightweight version)
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy everything from reporter folder
COPY . /app

# Install optional Python packages for report generation
RUN pip install --no-cache-dir jinja2 markdown

# Run report script
CMD ["python", "report.py"]
