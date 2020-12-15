FROM kowhai/ckan-base-lagoon:2.9

LABEL maintainer="brett@kowh.ai"

# Set timezone
ARG TZ
RUN echo $TZ > /etc/timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

# Copy all setup files
COPY setup ${APP_DIR}

COPY setup/supervisord.conf /etc/supervisord.conf
COPY setup/supervisor.uwsgi.conf /etc/supervisord.d/supervisor.uwsgi.conf

# Create local storage folder
RUN mkdir -p $CKAN_STORAGE_PATH && \
    chown -R ckan:ckan $CKAN_STORAGE_PATH

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

RUN chown ckan -R /srv/app

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --retries=5 CMD curl --fail http://localhost:5000/api/3/action/status_show || exit 1

CMD ["/srv/app/start_ckan.sh"]