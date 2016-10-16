FROM port/fedora:latest

ENV MHM_RELEASE v0.0.1rc3
ENV PYTHONPATH  /commissaire/src/

# Install required dependencies and commissaire-http
# NOTE: gcc, libffi-devel and openssl-devel are required to build some of the
#       dependencies when using pip. redhat-rpm-config has at least one file
#       referenced by one of the build dependencies.
RUN dnf -y install --setopt=tsflags=nodocs rsync openssh-clients redhat-rpm-config python-pip python-virtualenv git gcc libffi-devel openssl-devel ; dnf clean all
RUN git clone https://github.com/projectatomic/commissaire-mvp.git ./commissaire && \
virtualenv /environment && \
. /environment/bin/activate && \
cd commissaire && \
pip install -U pip && \
pip install -r requirements.txt && \
pip freeze > /installed-python-deps.txt

EXPOSE 8000
WORKDIR /commissaire
RUN mkdir -p /etc/commissaire
CMD . /environment/bin/activate && commissaire-server
