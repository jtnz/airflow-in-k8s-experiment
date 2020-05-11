FROM python:3.6-slim-buster

ARG DAG_DIR=/dags

RUN set -x \
    # Install airflow
    && apt-get update \
    && apt-get install -y gcc \
    && pip install apache-airflow[kubernetes,postgres,s3] \
    && apt-get purge -y gcc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    # Setup dags dir
    && useradd --create-home airflow \
    && mkdir ${DAG_DIR} \
    && chown airflow:airflow ${DAG_DIR}

ENV AIRFLOW__CORE__LOAD_EXAMPLES=false \
    AIRFLOW__CORE__DAGS_FOLDER=${DAG_DIR}

USER airflow

ENTRYPOINT [ "airflow" ]
