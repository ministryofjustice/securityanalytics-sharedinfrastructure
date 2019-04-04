FROM alpine:latest

RUN apk --update --no-cache add python3 nodejs nodejs-npm \
    && pip3 install awscli --upgrade \
    && wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
    && unzip terraform_0.11.13_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_0.11.13_linux_amd64.zip
