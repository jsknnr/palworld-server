FROM debian:12

ENV DEBIAN_FRONTEND "noninteractive"
ENV PALWORLD_PATH "/home/steam/palworld"
ENV PALWORLD_CONFIG "${PALWORLD_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"

RUN groupadd -g 1000 steam \
    && useradd -g 1000 -u 1000 -m steam \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        lib32gcc-s1

USER steam

COPY entrypoint.sh /home/steam/entrypoint.sh

RUN mkdir "$PALWORLD_PATH" \
    && mkdir "$PALWORLD_PATH"/Pal/Saved \
    && mkdir /home/steam/steamcmd \
    && mkdir -p /home/steam/.steam/sdk64 \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf - -C /home/steam/steamcmd \
    && chmod +x /home/steam/steamcmd/steamcmd.sh \
    && cp /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so 

WORKDIR /home/steam

CMD ["/home/steam/entrypoint.sh"]
