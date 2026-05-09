FROM python:3.11-alpine
WORKDIR /app
RUN apk upgrade --no-cache
RUN pip install --upgrade pip jaraco.context>=>6.1.0 wheel>=0.46.2

COPY app.py .

ENV APP_VERSION=v1.0.0
EXPOSE 8080
CMD ["python","app.py"]

