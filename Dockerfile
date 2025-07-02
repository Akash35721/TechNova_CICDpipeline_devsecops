




FROM python:3.8-slim


WORKDIR /app


COPY requirements.txt .


RUN pip install --no-cache-dir -r requirements.txt


COPY templates/ ./templates/
COPY static/ ./static/


COPY app.py .


CMD ["python", "app.py"]