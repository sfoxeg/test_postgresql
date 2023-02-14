FROM python:3.8.13-slim-buster
ENV PYTHONBUFFERED=1
ENV AIRFLOW_USER=airflow
ENV AIRFLOW_GROUP=airflow
ENV UID=5000
ENV AIRFLOW_DIR=/app
ENV SHARED_DIR=${AIRFLOW_DIR}/shared
ENV SRC_DIR=${AIRFLOW_DIR}/src
ENV AIRFLOW_HOME=${AIRFLOW_DIR}/airflow
ENV DEBIAN_FRONTEND=noninteractive
ENV AIRFLOW_PIP_VERSION=22.1.2
ENV AIRFLOW_VERSION=2.3.3
ENV PYTHONPATH=${SRC_DIR}

RUN apt update -y -q \
    && apt install -y -q --no-install-recommends \
    build-essential \
    freetds-bin \
    krb5-user \
    ldap-utils \
    libffi6 \
    libsasl2-2 \
    libsasl2-modules \
    libssl1.1 \
    locales \
    lsb-release \
    sasl2-bin \
    sqlite3 \
    unixodbc \
    postgresql-client-common \
    postgresql-client\
    gcc \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip
RUN pip install -U --no-cache-dir mimesis
RUN pip install -U --no-cache-dir postgres
RUN pip install -U --no-cache-dir redis
RUN pip install -U --no-cache-dir rabbit
RUN pip install -U --no-cache-dir psycopg[binary]
RUN pip install -U --no-cache-dir psycopg2-binary
RUN pip install -U --no-cache-dir apache-airflow-providers-postgres


RUN AIRFLOW_PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"; \
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${AIRFLOW_PYTHON_VERSION}.txt"; \
    pip install "apache-airflow[async,postgres,celery]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"


COPY app ${SRC_DIR}

RUN groupadd --system ${AIRFLOW_GROUP} \
    && useradd --system --home-dir ${AIRFLOW_DIR} --no-create-home --no-user-group --groups ${AIRFLOW_GROUP} --uid ${UID} ${AIRFLOW_USER} \
    && chown -R ${AIRFLOW_USER}:${AIRFLOW_GROUP} ${AIRFLOW_DIR}

WORKDIR ${SRC_DIR}

EXPOSE 8080

USER ${AIRFLOW_USER}