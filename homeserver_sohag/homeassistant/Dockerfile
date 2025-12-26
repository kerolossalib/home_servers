FROM homeassistant/home-assistant:stable

ENV UDEV=on

COPY start.sh /tmp/start.sh

# Download and install HACS
# RUN wget -O - https://get.hacs.xyz | bash -


RUN chmod +x /tmp/start.sh

CMD ["bash","/tmp/start.sh"]
