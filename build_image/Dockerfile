FROM python:3.7-alpine

RUN apk --update --no-cache add nodejs nodejs-npm git openssh docker \
    && pip3 install --upgrade awscli pipenv \
    && wget https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_amd64.zip \
    && unzip terraform_0.12.0_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_0.12.0_linux_amd64.zip
