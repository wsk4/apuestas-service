# ── Stage 1: dependencias ────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Solo copiamos requirements primero para aprovechar la caché de Docker
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir --prefix=/install -r requirements.txt


# ── Stage 2: imagen final ─────────────────────────────────────────────────────
FROM python:3.12-slim

# Usuario no-root (seguridad)
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copiar dependencias instaladas desde el stage builder
COPY --from=builder /install /usr/local

# Copiar el código fuente
COPY app/ ./app/

# Cambiar al usuario no-root antes de arrancar
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]