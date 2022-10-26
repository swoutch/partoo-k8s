# FROM python:3.10.8-slim
# COPY app.py /app
# WORKDIR /app
# RUN pip install --no-cache-dir flask
# EXPOSE 5001
# CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port", "5001"]
FROM python:3.6.12-alpine

COPY requirements.txt /
RUN pip3 install -r /requirements.txt

COPY . /app
WORKDIR /app

ENTRYPOINT ["gunicorn", "--chdir", "app", "app:app", "-w", "2", "--threads", "2", "-b", "0.0.0.0:80"]
