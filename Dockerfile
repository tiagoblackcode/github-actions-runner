FROM summerwind/actions-runner:latest

RUN sudo mv /usr/local/bin/docker /usr/local/bin/docker.bin

COPY docker-shim.sh /usr/local/bin/docker

RUN sudo chmod +x /usr/local/bin/docker && \
    sudo chown root:root /usr/local/bin/docker 
