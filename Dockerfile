FROM python:3.9-alpine3.13
LABEL maintainer="igorciesielski"

ENV PYTHONUNBUFFERED 1


COPY ./requirements.txt /tmp/requirements.txt
#linting (dev env)
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000 

#default value (default = not(dev env))
ARG DEV=false
#create virtual env
RUN python -m venv /py && \
    #upgrade pip (package installer)
    /py/bin/pip install --upgrade pip && \
    #postgresql-client
    apk add --update --nocache postgresql-client && \
    #postgresql-client dependencies
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    #install required packages
    /py/bin/pip install -r /tmp/requirements.txt && \
    #jesli w komendzie ustalimy nasz arg DEV na true to uruchomimy wersje dev (linting etc)
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi &&  \
    #remove temp txt file (docker image must be as lightweight as possible)
    rm -rf /tmp && \
    #remove temp postgresql-client required dependencies
    apk del .tmp-build-deps && \
    #DO NOT USE ROOT USER IN DOCKER IMAGES (FULL ACCESS)
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH" 


USER django-user
