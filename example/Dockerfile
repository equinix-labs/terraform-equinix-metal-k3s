FROM ubuntu:bionic
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
COPY app.py .
COPY requirements.txt .
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]
