FROM python:3.9-alpine

WORKDIR /app

COPY requirements_loadgen.txt .
RUN pip install -r requirements_loadgen.txt

COPY load_gen.py .

CMD ["python", "load_gen.py"]

