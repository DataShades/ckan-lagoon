#!/bin/bash

# Run the prerun script to init CKAN and create the default admin user
sudo -u ckan -EH python3 prerun.py

# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
        echo
    done
fi

# Ensure correct permissions for CKAN storage
mkdir -p ${CKAN_STORAGE_PATH}/storage/uploads/user && mkdir -p ${CKAN_STORAGE_PATH}/resources
chown -R ckan:ckan ${CKAN_STORAGE_PATH} ${APP_DIR} && chmod -R 777 ${CKAN_STORAGE_PATH}

# Set site URL
crudini --set  ${CKAN_INI} app:main ckan.site_url ${CKAN_SITE_URL}

# Set global theme
crudini --set  ${CKAN_INI} app:main ckan.site_title ${CKAN_SITE_TITLE}

# Set default locale
crudini --set  ${CKAN_INI} app:main ckan.locale_default en_AU

# Configure global search
crudini --set  ${CKAN_INI} app:main ckan.search.show_all_types datasets

# Enable Datastore and XLoader extension in CKAN configuration
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins datastore
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins xloader

# Set up datastore permissions
ckan datastore set-permissions | psql "${CKAN_SQLALCHEMY_URL}"

# Set XLoader database URI
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckanext.xloader.jobs_db.uri ${CKAN_SQLALCHEMY_URL}

### Add custom CKAN extensions to configuration

# ckanext-scheming
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins scheming_organizations
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins scheming_datasets
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins scheming_groups

# ckanext-harvest
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins harvest

# ckanext-syndicate
crudini --set --list --list-sep=' ' ${CKAN_INI} app:main ckan.plugins syndicate
ckan syndicate init
<<<<<<< Updated upstream

# logging changes - set to DEBUG for all
crudini --set  ${CKAN_INI} logger_root level DEBUG
crudini --set  ${CKAN_INI} logger_werkzeug level DEBUG
crudini --set  ${CKAN_INI} logger_ckan level DEBUG
crudini --set  ${CKAN_INI} logger_ckanext level DEBUG
=======
>>>>>>> Stashed changes

# Merge extension configuration options into main CKAN config file.
crudini --merge ${CKAN_INI} < ${APP_DIR}/extension-configs.ini

# Check whether http basic auth password protection is enabled and enable basicauth routing on uwsgi respecfully
if [ $? -eq 0 ]
then
  if [ "$PASSWORD_PROTECT" = true ]
  then
    if [ "$HTPASSWD_USER" ] || [ "$HTPASSWD_PASSWORD" ]
    then
      # Generate htpasswd file for basicauth
      htpasswd -d -b -c /srv/app/.htpasswd $HTPASSWD_USER $HTPASSWD_PASSWORD
      # Start supervisord
      echo "[start_ckan.sh] Starting supervisord."
      supervisord --configuration /etc/supervisord.conf &
    else
      echo "Missing HTPASSWD_USER or HTPASSWD_PASSWORD environment variables. Exiting..."
      exit 1
    fi
  else
    echo "[start_ckan.sh] Starting supervisord."
    # Start supervisord
    supervisord --configuration /etc/supervisord.conf
  fi
else
  echo "[prerun] failed...not starting CKAN."
fi

