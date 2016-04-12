FROM praekeltfoundation/supervisor
MAINTAINER Praekelt Foundation <dev@praekeltfoundation.org>

# See http://graphite.readthedocs.org/en/0.9.15/install-pip.html

ENV GRAPHITE_VERSION "0.9.15"
RUN apt-get-install.sh libcairo2
# Install graphite-web dependencies
# graphite-web as of version 0.9.15 doesn't set any `install_requires` in its
# setup.py so we have to install these manually.
# http://graphite.readthedocs.org/en/0.9.15/install.html#dependencies
# https://github.com/graphite-project/graphite-web/blob/0.9.15/requirements.txt
RUN pip install cairocffi \
                Django==1.4 \
                django-tagging==0.3.1 \
                gunicorn \
                pytz \
                txAMQP
RUN pip install "whisper==${GRAPHITE_VERSION}" \
                "carbon==${GRAPHITE_VERSION}" \
                "graphite-web==${GRAPHITE_VERSION}"

# Graphite installs into /opt somehow
ENV GRAPHITE_ROOT "/opt/graphite"
ENV PYTHONPATH="$GRAPHITE_ROOT/lib:$GRAPHITE_ROOT/webapp" \
    DJANGO_SETTINGS_MODULE="graphite.settings" \
    PATH="$PATH:$GRAPHITE_ROOT/bin"
WORKDIR $GRAPHITE_ROOT

# Set up basic config
RUN cp conf/graphite.wsgi.example webapp/graphite/wsgi.py && \
    cp conf/carbon.conf.example conf/carbon.conf && \
    cp conf/storage-schemas.conf.example conf/storage-schemas.conf

COPY ./local_settings.py /opt/graphite/webapp/graphite

# Copy in supervisor configs
COPY ./supervisor /etc/supervisor/conf.d

EXPOSE 8000
VOLUME /opt/graphite/storage

COPY ./bootstrap.sh /scripts
CMD ["bootstrap.sh"]