# Stage 1: Builder
FROM python:3.10-slim AS builder

WORKDIR /app

RUN pip install --no-cache-dir --upgrade pip wheel

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final
FROM python:3.10-slim AS final

# Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /install /usr/local
COPY app.py .
COPY templates/ templates/

RUN useradd --no-create-home appuser && chown -R appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
