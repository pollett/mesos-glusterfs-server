FROM ubuntu:latest

ENV SERVICE_NAME "gluster"
ENV GLUSTER_DATA "/data"
ENV GLUSTER_VOLUMES "mesosvol"
ENV GLUSTER_TRANSPORT "tcp"
ENV GLUSTER_REPLICA 2
# Use it ig you should stripe your module
#ENV GLUSTER_STRIPE 1
# Use it if you should put some quota on your volume
#ENV GLUSTER_QUOTA "10GB"


RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:gluster/glusterfs-3.7 && \
    apt-get update && \
    apt-get install -y glusterfs-server glusterfs-client python-pip git


RUN mkdir /data

# Install python lib to manage glusterfs
RUN pip install marathon
WORKDIR /usr/src
RUN git clone https://github.com/disaster37/python-gluster.git
WORKDIR /usr/src/python-gluster
RUN python setup.py install

# Add some script to init the glusterfs cluster
ADD assets/init.py /app/
RUN chmod +x /app/init.py
ADD assets/run /app/
RUN chmod +x /app/run


WORKDIR /app
VOLUME ["${GLUSTER_DATA}", "/var/lib/glusterd" ]


# CLEAN APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/app/run" ]
