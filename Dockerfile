FROM nginx:1.17.3
LABEL maintainer="Quirian Cordova"

# ANSIBLE_STDOUT_CALLBACK - nicer output from the playbook run
ENV LANG=en_US.UTF-8 \
    PYTHONDONTWRITEBYTECODE=yes \
    WORKDIR=/src \
    ANSIBLE_STDOUT_CALLBACK=debug

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*
RUN dnf install -y ansible && dnf clean all

RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf


COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/
WORKDIR /src
COPY . /src

RUN ansible-playbook -vv -c local -i localhost, files/install-packages.yaml \
    && dnf clean all

# install conu
RUN pip3 install .

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
