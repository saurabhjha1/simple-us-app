FROM  python:3.9-alpine

WORKDIR /app
RUN apk add --no-cache build-base \
    linux-headers \
    gcc \
    g++ \
    libc-dev \
    libstdc++ \
    python3-dev \
    musl-dev
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap --action=install
COPY app.py .
ENV OTEL_PYTHON_DISABLED_INSTRUMENTATIONS=aws_lambda
CMD [ "opentelemetry-instrument",  "--log_level", "debug", "python", "app.py" ]
