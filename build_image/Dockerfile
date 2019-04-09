FROM python:3.7-alpine

RUN apk --update --no-cache add nodejs nodejs-npm git openssh \
    && pip3 install --upgrade awscli pipenv \
    && wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
    && unzip terraform_0.11.13_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_0.11.13_linux_amd64.zip
