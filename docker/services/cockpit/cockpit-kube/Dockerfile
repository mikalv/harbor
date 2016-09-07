FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="cockpit"

RUN curl -L https://copr.fedorainfracloud.org/coprs/g/cockpit/cockpit-preview/repo/fedora-24/group_cockpit-cockpit-preview-fedora-24.repo > /etc/yum.repos.d/group_cockpit-cockpit-preview-fedora-24.repo && \
    dnf install -y \
      'dnf-command(download)' && \
    mkdir -p  /tmp/rpms && \
    dnf download cockpit-bridge --destdir /tmp/rpms && \
    rpm --nodeps -i /tmp/rpms/*.x86_64.rpm && \
    rm -rf /tmp/rpms/* && \
    dnf download cockpit-shell --destdir /tmp/rpms && \
    rpm --nodeps -i /tmp/rpms/*.noarch.rpm && \
    rm -rf /tmp/rpms/* && \
    dnf download cockpit-ws --destdir /tmp/rpms && \
    rpm --nodeps -i /tmp/rpms/*.x86_64.rpm && \
    rm -rf /tmp/rpms/* && \
    dnf download cockpit-kubernetes --destdir /tmp/rpms && \
    rpm --nodeps -i /tmp/rpms/*.x86_64.rpm && \
    rm -rf /tmp/rpms/* && \
    rm -rf /usr/share/cockpit/realmd/ /usr/share/cockpit/system/ /usr/share/cockpit/tuned/ /usr/share/cockpit/users/ /usr/share/cockpit/dashboard/ && \
    rm -rf /usr/bin/cockpit-bridge && \
    rm -rf /usr/lib64/security/pam_reauthorize.so && \
    rm -rf /usr/libexec/cockpit-polkit && \
    rm -rf /etc/cockpit/ && \
    mkdir -p /etc/cockpit/ && \
    chmod 775 /etc && \
    chmod 775 /etc/cockpit && \
    chmod 775 /etc/os-release && \
    chmod 775 /usr/share/cockpit/shell && \
    chmod 775 /usr/share/cockpit/kubernetes && \
    mv /usr/share/cockpit/kubernetes/index.html.gz /usr/share/cockpit/kubernetes/original-index.gz



kind: List
apiVersion: v1
items:
 -
   kind: ReplicationController
  apiVersion: v1
  metadata:
   name: "kubernetes-cockpit"
   labels:
    name: "kubernetes-cockpit"
  spec:
   replicas: 1
   selector:
    name: "kubernetes-cockpit"
   template:
    metadata:
     labels:
      name: "kubernetes-cockpit"
    spec:
     containers:
      -
   name: "kubernetes-cockpit"
       image: "cockpit/kubernetes:latest"
       ports:
        -
   containerPort: 9090
         protocol: TCP
       env:
        -
   name:
         value: false

apiVersion: v1
kind: ReplicationController
metadata:
  labels:
    openstack-app: kubernetes-cockpit
    version: v0.1.0
  name: kubernetes-cockpit
  namespace: default
spec:
  replicas: 1
  template:
    metadata:
      labels:
        openstack-app: kubernetes-cockpit
        version: v0.1.0
      name: kubernetes-cockpit
      namespace: default
    spec:
      hostNetwork: true
      nodeSelector:
        harbor-role: master
      containers:
       - name: kubernetes-cockpit
         image: docker.io/cockpit/kubernetes:latest
         imagePullPolicy: Always
         ports:
           - containerPort: 9090
             protocol: TCP
             name: https
         env:
           - name: OS_DOMAIN
             value: harboros.net
           - name: KUBE_INSECURE
             value: "true"
           - name: KUBERNETES_MASTER
             value: http://127.0.0.1:8080
           - name: KUBERNETES_SERVICE_HOST
             value: kubernetes.default.svc.harboros.net
           - name: KUBERNETES_SERVICE_PORT
             value: "6443"
