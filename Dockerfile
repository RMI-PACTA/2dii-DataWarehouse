FROM python:3.8.0-buster
LABEL "Name"="2 Degrees Data Warehouse Bootstrap and Import"
LABEL "Version"="0.1.0"
LABEL "Maintainer"="Alex@2degrees-investing.org"

WORKDIR /usr/src/app

COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .
COPY sql/ sql/

CMD ["python", "./twodii_datawarehouse.py"]
