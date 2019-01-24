FROM ruby:2.6.0

RUN mkdir -p /app/source
WORKDIR /app/source
ADD . /app/source

RUN apt-get update && \
	apt-get install -y --no-install-recommends bash vim g++ make && \
	rm -rf /var/lib/apt/lists/*

CMD /bin/bash
