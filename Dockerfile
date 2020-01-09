FROM python:3.8.0-buster
LABEL "Name"="2 Degrees Data Warehouse Bootstrap and Import"
LABEL "Version"="0.1.0"
LABEL "Maintainer"="Alex@2degrees-investing.org"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  # netcat is needed for the wait-for script
  netcat=1.10-41.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
ENV PYTHONPATH "$PYTHONPATH:/usr/src/app"

COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY scripts/ /usr/src/scripts/
ENV PATH "$PATH:/usr/src/scripts/"
RUN ["chmod", "-Rvv", "+x", "/usr/src/scripts/"]

COPY app/ ./
COPY sql/ /usr/src/sql/

RUN groupadd -r twodii && useradd --no-log-init -r -g twodii twodii
RUN chown -R twodii: /tmp /usr/src/
USER twodii

CMD [ \
  "wait-for.sh",  "db:5432", "--", \
  "python", "./twodii_datawarehouse.py", "-v" \
  ]
