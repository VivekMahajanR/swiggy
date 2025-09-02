# Build stage
FROM python:3.12-slim as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements-dockers.txt ./
RUN pip install --user -r requirements-dockers.txt

# Final stage
FROM python:3.12-slim

# Install lightgbm runtime dependency only
RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local
COPY app.py ./
COPY ./models/preprocessor.joblib ./models/preprocessor.joblib
COPY ./scripts/data_clean_utils.py ./scripts/data_clean_utils.py
COPY ./run_information.json ./

# Add user packages to PATH
ENV PATH=/root/.local/bin:$PATH

EXPOSE 8000

CMD ["python", "./app.py"]