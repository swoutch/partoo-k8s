FROM python:3.6.12-alpine

RUN pip3 install Flask==1.1.2 gunicorn==20.0.4

COPY . /app
WORKDIR /app

ENTRYPOINT ["gunicorn", "--chdir", "app", "app:app", "-w", "2", "--threads", "2", "-b", "0.0.0.0:80"]
