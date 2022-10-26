FROM python:3.10.8-alpine

RUN pip install Flask==2.2.2

COPY ./app.py /

ENTRYPOINT ["flask", "run", "--port=80", "--host=0.0.0.0"]
