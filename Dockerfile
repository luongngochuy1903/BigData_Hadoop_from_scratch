FROM ubuntu:22.04

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        openjdk-8-jdk \
        sudo \
        wget \
        net-tools \
        iputils-ping && \
    apt-get clean

RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz && \
    tar -xzf hadoop-3.4.1.tar.gz && \
    mv hadoop-3.4.1 /usr/local/hadoop && \
    rm hadoop-3.4.1.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# ssh without password
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys

RUN mkdir -p /root/hdfs/namenode && \
    mkdir -p /root/hdfs/datanode && \
    mkdir -p $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config /root/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    mv /tmp/start-hadoop.sh /root/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh /root/run-wordcount.sh

RUN sed -i 's/\r$//' /root/*.sh && \
    sed -i 's/\r$//' $HADOOP_HOME/etc/hadoop/*.sh \
    sed -i 's/\r$//' /usr/local/hadoop/etc/hadoop/workers

RUN chmod +x /root/start-hadoop.sh && \
    chmod +x /root/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh

CMD ["bash", "-c", "service ssh start && bash"]
