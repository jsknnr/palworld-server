#!/bin/bash

# Validate arguments
if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME="Palworld Containerized"
    echo "WARN: SERVER_NAME not set, using default: Palworld Containerized"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "ERROR: SERVER_PASSWORD not set, exitting"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT="8211"
    echo "WARN: GAME_PORT not set, using default: 8211"
fi

if [ -z "$SERVER_SLOTS" ]; then
    SERVER_SLOTS="32"
    echo "WARN: SERVER_SLOTS not set, using default: 32"
fi

# Install/Update Palworld
echo "INFO: Updating Palworld Dedicated Server"
/home/steam/steamcmd/steamcmd.sh +force_install_dir "$PALWORLD_PATH" +login anonymous +app_update 2394010 validate +quit

# Palworld looks for steamclient.so here, so lets make sure it exists here
cp /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so 

# Check for proper save permissions
if ! touch "${PALWORLD_PATH}/Pal/Saved/test"; then
    echo ""
    echo "ERROR: The ownership of /home/steam/palworld/Pal/Saved is not correct and the server will not be able to save..."
    echo "the directory that you are mounting into the container needs to be owned by 10000:10000"
    echo "from your container host attempt the following command 'chown -R 10000:10000 /your/palworld/directory'"
    echo ""
    exit 1
fi

rm "${PALWORLD_PATH}/Pal/Saved/test"

# Copy example server config if not already present
if ! [ -f "${PALWORLD_CONFIG}" ]; then
    echo "INFO: Palworld server config not present, copying example"
    mkdir -p "${PALWORLD_PATH}/Pal/Saved/Config/LinuxServer"
    touch ${PALWORLD_CONFIG}
    cat /home/steam/palworld/DefaultPalWorldSettings.ini > ${PALWORLD_CONFIG}
# Config may be present but empty, check for that too
elif [ $(ls -l ${PALWORLD_CONFIG} | awk '{print $5}') -eq 0 ]; then
    echo "INFO: Palworld server config empty, copying example"
    cat /home/steam/palworld/DefaultPalWorldSettings.ini > ${PALWORLD_CONFIG}
fi

# Update config
sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"${SERVER_NAME}\"/" $PALWORLD_CONFIG
sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"${SERVER_PASSWORD}\"/" $PALWORLD_CONFIG
sed -i "s/PublicPort=\"[^\"]*\"/PublicPort=\"${GAME_PORT}\"/" $PALWORLD_CONFIG
sed -i "s/ServerPlayerMaxNum=\"[^\"]*\"/ServerPlayerMaxNum=\"${SERVER_SLOTS}\"/" $PALWORLD_CONFIG

# Launch Palworld
${PALWORLD_PATH}/PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS -EpicApp=Palserver
