FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="jakob@bchrd.ca"

# Download p4d and p4
ADD https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4d /usr/local/bin/p4d
ADD https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4 /usr/local/bin/p4
RUN chmod 755 /usr/local/bin/p4d /usr/local/bin/p4

# Create the perforce user
RUN useradd -ms /bin/bash perforce
USER perforce

# Create the perforce directories
WORKDIR /app
ADD scripts /app

# Set the default perforce environment variables
ENV P4PORT=1666
ENV P4ROOT=/app/perforce/root
ENV P4JOURNAL=/app/perforce/journals/journal
ENV P4SSLDIR=/app/perforce/ssl

# Start the perforce server
ENTRYPOINT ["bash", "/app/start.sh"]
