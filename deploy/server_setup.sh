#!/usr/bin/env bash



set -e



# TODO: Set to URL of git repo.

PROJECT_GIT_URL='https://github.com/akash4992/profileapi.git'



PROJECT_BASE_PATH='/usr/local/apps'

VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'



# Set Ubuntu Language

locale-gen en_GB.UTF-8



# Install Python, SQLite and pip

echo "Installing dependencies..."

apt-get update

apt-get install -y python3-dev python3-venv sqlite python-pip supervisor nginx git



mkdir -p $PROJECT_BASE_PATH

git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH/profiles-rest-api



mkdir -p $VIRTUALENV_BASE_PATH

python3 -m venv $VIRTUALENV_BASE_PATH/profiles_api



$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install -r $PROJECT_BASE_PATH/profiles-rest-api/requirements.txt



# Run migrations

cd $PROJECT_BASE_PATH/profiles-rest-api/src



# Setup Supervisor to run our uwsgi process.

cp $PROJECT_BASE_PATH/profile-rest-api/deploy/supervisor_profile_app.conf /etc/supervisor/conf.d/profile_app.conf

supervisorctl reread

supervisorctl update

supervisorctl restart profiles_api



# Setup nginx to make our application accessible.

cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/nginx_profile_app.conf /etc/nginx/sites-available/profile_app.conf

rm /etc/nginx/sites-enabled/default

ln -s /etc/nginx/sites-available/profile_app.conf /etc/nginx/sites-enabled/profile_app.conf

systemctl restart nginx.service



echo "DONE! :)"