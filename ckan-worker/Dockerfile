FROM kowhai/ckan-base-lagoon:2.9

LABEL maintainer="brett@kowh.ai"

# Set timezone
ARG TZ
RUN echo $TZ > /etc/timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

COPY setup/supervisor.worker.conf /etc/supervisord.d/worker.conf

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

RUN chown ckan -R /srv/app

CMD ["/srv/app/start_ckan.sh"]