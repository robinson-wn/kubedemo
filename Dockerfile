# Build spark image to run on Kubernetes
# See https://levelup.gitconnected.com/spark-on-kubernetes-3d822969f85b
#FROM newfrontdocker/spark-py:v3.0.1-j14
# https://hub.docker.com/r/datamechanics/spark
FROM datamechanics/spark:3.2-latest

# Run installation tasks as root
USER 0

# Specify the official Spark User, working directory, and entry point
WORKDIR /opt/spark/work-dir

# app dependencies
# Spark official Docker image names for python
ENV APP_DIR=/opt/spark/work-dir \
    PYTHON=python3 \
    PIP=pip3

# Preinstall dependencies
COPY requirements.txt ${APP_DIR}

# Conda fails when trying to install pyspark with a version number and fails to install wget
# && ${PIP} install --trusted-host pypi.python.org pyspark==3.2.1 wget \
RUN conda install --file requirements.txt \
    && ${PIP} install wget \
    && rm -f ${APP_DIR}/requirements.txt

# Specify the User that the actual main process will run as
ARG spark_uid=185

RUN useradd -d /home/spark -ms /bin/bash -u ${spark_uid} spark \
    && chown -R spark /opt/spark/work-dir
USER ${spark_uid}

# Copy code files
COPY --chown=spark ./demo ${APP_DIR}/demo
