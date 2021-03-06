FROM erlang:19.2.3
MAINTAINER Heinz N. Gies <heinz@project-fifo.net>

###################
##
## Get DalmatinerDB
##
###################

ENV DDB_VSN=0.3.4p1
ENV DDB_PATH=/dalmatinerdb

RUN cd / \
    && env GIT_SSL_NO_VERIFY=true git clone -b $DDB_VSN https://github.com/vshulkin/dalmatinerdb.git dalmatinerdb.git

RUN cd dalmatinerdb.git \
    && env GIT_SSL_NO_VERIFY=true git fetch \
    && env GIT_SSL_NO_VERIFY=true git checkout $DDB_REF \
    && ./rebar3 as smartos release \
    && mkdir $DDB_PATH \
    && mv /dalmatinerdb.git/_build/smartos/rel/ddb/* $DDB_PATH \
    && rm -rf /dalmatinerdb.git \
    && rm -rf $DDB_PATH/lib/*/c_src \
    && rm -rf ~/.hex

RUN mkdir -p /data/dalmatinerdb/etc \
    && mkdir -p /data/dalmatinerdb/db \
    && mkdir -p /data/dalmatinerdb/log \
    && cp $DDB_PATH/etc/ddb.conf /data/dalmatinerdb/etc/ \
    && echo "none() -> drop." > /data/dalmatinerdb/etc/rules.ot \
    && sed -i -e '/RUNNER_USER=/d' $DDB_PATH/bin/ddb \
    && sed -i -e '/RUNNER_USER=/d' $DDB_PATH/bin/ddb-admin

COPY ddb.sh /

EXPOSE 5555

ENTRYPOINT ["/ddb.sh"]
