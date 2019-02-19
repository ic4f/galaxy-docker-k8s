FROM ubuntu:18.04 as builder
ARG DEBIAN_FRONTEND=noninteractive 


# Install misc. build tools
RUN apt-get -qq update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    git \
    make \
    npm \
    nodejs \
    python-pip \
    python-virtualenv \ 
    software-properties-common \ 
    sudo \
    virtualenv \
    wget \
    && pip install requests \
    && npm install -g yarn 

# declare vars
ARG ROOT_DIR=/galaxy
ARG SERVER_DIR=$ROOT_DIR/server 
ARG DOWNLOAD_URL=https://github.com/galaxyproject/galaxy/archive/release_18.09.tar.gz
ARG VENV_DIR=$SERVER_DIR/.venv
ARG CONFIG_DIR=$SERVER_DIR/config
ARG SHED_TOOLS_DIR=$ROOT_DIR/shed_tools
ARG FILES=files
ARG GALAXY_CONFIG_FILE=$FILES/galaxy.yml 
ARG GALAXY_REQUIREMENTS_FILE=$SERVER_DIR/lib/galaxy/dependencies/pinned-requirements.txt

# Get galaxy
RUN mkdir -p $SERVER_DIR \
    && wget -q -O - $DOWNLOAD_URL | tar xzf - --strip-components=1 -C $SERVER_DIR

# Setup virtualenv
RUN virtualenv $VENV_DIR

# Make static config directories
RUN mkdir -p $CONFIG_DIR
RUN mkdir -p $SHED_TOOLS_DIR

#install additional config files?

# Create galaxy config file
COPY $GALAXY_CONFIG_FILE $CONFIG_DIR/

# Install base dependencies
WORKDIR $SERVER_DIR
RUN . $VENV_DIR/bin/activate \
    && pip install -r $GALAXY_REQUIREMENTS_FILE --index-url https://wheels.galaxyproject.org/simple/ --extra-index-url https://pypi.python.org/simple \
    && deactivate

# Collect and install conditional dependencies (hardcoded for now)
RUN . $VENV_DIR/bin/activate \
    && pip install psycopg2-binary==2.7.4 --index-url https://wheels.galaxyproject.org/simple/ --extra-index-url https://pypi.python.org/simple \
    && deactivate

# Make mutable config directories
RUN mkdir -p $CONFIG_DIR
RUN mkdir -p $CONFIG_DIR/dependencies

# Init mutable files
RUN cp $CONFIG_DIR/shed_tool_conf.xml.sample $SERVER_DIR/shed_tool_conf.xml
RUN cp $CONFIG_DIR/migrated_tools_conf.xml.sample $SERVER_DIR/migrated_tools_conf.xml
RUN cp $CONFIG_DIR/shed_data_manager_conf.xml.sample $SERVER_DIR/shed_data_manager_conf.xml
RUN cp $CONFIG_DIR/shed_tool_data_table_conf.xml.sample $SERVER_DIR/shed_tool_data_table_conf.xml

#db management
# TODO (if needed)

#error doc
# TODO

# Build the client; remove node_modules
WORKDIR $SERVER_DIR
RUN make client-production && rm $SERVER_DIR/client/node_modules -rf

# Start new build stage for final image
FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive 
# Declare new var + redeclare old vars to use at this stage
# (TODO: move up when done with dev)
# NOTE: the value of GALAXY_USER is hardcoded in the COPY instruction below
ARG GALAXY_USER=galaxy
ARG ROOT_DIR=/galaxy
ARG SERVER_DIR=$ROOT_DIR/server 

# Install galaxy runtime requirements; clean up; add user+group; make dir; change perms
RUN apt-get -qq update && apt-get install -y --no-install-recommends python-virtualenv \
      && apt-get autoremove -y && apt-get clean \
      && rm -rf /var/lib/apt/lists/*  /tmp/* && rm -rf ~/.cache/ \
      && adduser --system --group $GALAXY_USER \
      && mkdir -p $SERVER_DIR && chown $GALAXY_USER:$GALAXY_USER $ROOT_DIR -R

WORKDIR $ROOT_DIR
# Copy galaxy files to final image
# The chown values MUST be hardcoded (see #35018 at github.com/moby/moby)
COPY --chown=galaxy:galaxy --from=builder $ROOT_DIR .

WORKDIR $SERVER_DIR
EXPOSE 8080
USER $GALAXY_USER

# and run it!
CMD . .venv/bin/activate && uwsgi --yaml config/galaxy.yml
