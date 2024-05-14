FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="jakob@bchrd.ca"

# Create the perforce user
RUN useradd -ms /bin/bash perforce

# Install cron
RUN apt-get update && apt-get install -y cron nano

# Give the perforce user access to the cron daemon
RUN echo "perforce ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

# Download p4d and p4
ADD https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4d /usr/local/bin/p4d
RUN chmod 755 /usr/local/bin/p4d
ADD https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4 /usr/local/bin/p4
RUN chmod 755 /usr/local/bin/p4

# Use the perforce user for the rest of the commands
USER perforce

# Create the perforce directories
WORKDIR /opt/perforce
COPY start.sh /start.sh

# Set the default perforce environment variables
ENV P4PORT=1666
ENV P4ROOT=/opt/perforce/root
ENV P4JOURNAL=/opt/perforce/journals/journal
ENV P4SSLDIR=/opt/perforce/ssl

# Start the perforce server
ENTRYPOINT ["bash", "/start.sh"]
