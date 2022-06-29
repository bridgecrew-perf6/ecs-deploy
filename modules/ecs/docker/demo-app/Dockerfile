FROM python:latest
LABEL maintainer="@JManzur"

WORKDIR /usr/src/app

COPY app.py /usr/src/app/
COPY templates/index.html /usr/src/app/templates/
COPY requirements.txt /usr/src/app/

RUN apt-get update && apt-get install stress htop iputils-ping jq telnet -y
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 8082
CMD ["python", "/usr/src/app/app.py"]