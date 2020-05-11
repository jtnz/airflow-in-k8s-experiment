#!/usr/bin/env bash

set -ex

airflow initdb

exec airflow webserver -p 8080
