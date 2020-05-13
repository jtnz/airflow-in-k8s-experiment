FROM python:3.6-slim-buster

ENV AIRFLOW_HOME=/opt/airflow

ARG DAG_DIR=${AIRFLOW_HOME}/dags
ARG AIRFLOW_VERSION=1.10.10

RUN set -x \
    # Install airflow
    && apt-get update \
    && apt-get install -y gcc \
    && pip install apache-airflow[kubernetes,postgres,aws]==${AIRFLOW_VERSION} \
    && apt-get purge -y gcc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    # Setup airflow user and dirs
    && useradd --home-dir ${AIRFLOW_HOME} airflow \
    && mkdir -p ${DAG_DIR} \
    && chown airflow:airflow -R ${AIRFLOW_HOME}

WORKDIR ${AIRFLOW_HOME}

COPY py/ /usr/local/lib/python3.6/site-packages/airflow

USER airflow

ENTRYPOINT [ "airflow" ]
