FROM ubuntu
RUN apt-get update && apt-get install -y ncdu tcpdump tshark tree dnsutils iproute2 wget
RUN wget https://aka.ms/downloadazcopy-v10-linux && tar -zxf downloadazcopy-v10-linux && cd azcopy_linux_amd64* && mv azcopy /usr/bin/
