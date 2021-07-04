FROM kowhai/ckan-base-lagoon:2.9

LABEL maintainer="brett@kowh.ai"

# Set timezone
ARG TZ
RUN echo $TZ > /etc/timezone
#RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install CKAN extensions
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-xloader.git@testdocker#egg=ckanext-xloader' && \ 
    pip3 install -r ${APP_DIR}/src/ckanext-xloader/requirements.txt && \
<<<<<<< Updated upstream
    pip3 install -U requests[security]

RUN pip3 install -e 'git+https://github.com/DataShades/ckanext-harvest.git@py3#egg=ckanext-harvest' && \
=======
    pip3 install -U requests[security] && \
    #pip3 install -e 'git+https://github.com/DataShades/ckanext-harvest.git@py3#egg=ckanext-harvest' && \
    pip3 install -e 'git+https://github.com/ckan/ckanext-harvest.git@master#egg=ckanext-harvest' && \
>>>>>>> Stashed changes
    pip3 install -r ${APP_DIR}/src/ckanext-harvest/pip-requirements.txt && \
    pip3 install -e 'git+https://github.com/DataShades/ckanext-syndicate@py3#egg=ckanext-syndicate' && \
    pip3 install -r ${APP_DIR}/src/ckanext-syndicate/requirements.txt && \
    pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'
    
# Install crudini for configuration management
ADD https://raw.githubusercontent.com/pixelb/crudini/master/crudini /usr/local/bin/crudini
RUN pip install iniparse && \
    chmod +x /usr/local/bin/crudini

# Copy all setup files
COPY setup ${APP_DIR}
COPY setup/supervisord.conf /etc/supervisord.conf
COPY setup/supervisor.uwsgi.conf /etc/supervisord.d/supervisor.uwsgi.conf
COPY setup/supervisor.worker.conf /etc/supervisord.d/supervisor.worker.conf
COPY setup/supervisor.harvest.conf /etc/supervisord.d/supervisor.harvest.conf

# Copy templated extension configuration
COPY setup/extension-configs.ini ${APP_DIR}/extension-configs.ini

# Create local storage folder
RUN mkdir -p $CKAN_STORAGE_PATH && \
    chown -R ckan:ckan $CKAN_STORAGE_PATH

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

RUN chown ckan -R /srv/app

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --retries=5 CMD curl --fail http://localhost:5000/api/3/action/status_show || exit 1

CMD ["/srv/app/start_ckan.sh"]