FROM ubuntu:latest

RUN echo "Configurating Terraform environment"
RUN apt-get install wget zip -y
RUN wget https://releases.hashicorp.com/terraform/0.14.0/terraform_0.14.0_linux_amd64.zip
RUN unzip terraform_0.14.0_linux_amd64.zip -d /opt/
RUN chmod +x /opt/terraform

