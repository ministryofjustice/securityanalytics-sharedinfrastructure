FROM alpine:latest

RUN apk --update --no-cache add python3 nodejs nodejs-npm
RUN pip3 install awscli --upgrade
RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
RUN unzip terraform_0.11.13_linux_amd64.zip
RUN mv terraform /usr/bin
RUN rm terraform_0.11.13_linux_amd64.zip
