# ================================
# Stage 1: Builder
# ================================
FROM python:3.10-slim AS builder

WORKDIR /app

# Install dependencies into a local directory
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ================================
# Stage 2: Final image
# ================================
FROM python:3.10-slim AS final

WORKDIR /app

# Copy only the installed packages from builder
COPY --from=builder /install /usr/local

# Copy app files
COPY app.py .
COPY templates/ templates/

# Non-root user for security
RUN useradd --no-create-home appuser && chown -R appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
