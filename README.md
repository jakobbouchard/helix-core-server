# Helix Core Server

This image provides a simple way to get started with a Helix Core Server (Perforce).

## Usage

### Docker Compose without SSL

```yaml
services:
  perforce:
    image: jakobbouchard/helix-core-server:latest
    ports:
      - "1666:1666"
    environment:
      P4ROOT: /opt/perforce/root
      P4SSLDIR: /opt/perforce/ssl
      P4JOURNAL: /opt/perforce/journals/journal
      P4PORT: 1666
    volumes:
      - ./data:/opt/perforce
    restart: unless-stopped
```

### Docker Compose with SSL

```yaml
services:
  perforce:
    image: jakobbouchard/helix-core-server:latest
    ports:
      - "1666:1666"
    environment:
      SSL_COUNTRY: CA
      SSL_STATE: Quebec
      SSL_LOCALITY: Montreal
      SSL_ORGANIZATION: Organization
      SSL_ORGANIZATIONAL_UNIT: DevOps
      SSL_COMMON_NAME: localhost # must be a valid hostname
      SSL_EXPIRY: 365 # days
      P4ROOT: /opt/perforce/root
      P4SSLDIR: /opt/perforce/ssl
      P4JOURNAL: /opt/perforce/journals/journal
      P4PORT: ssl:1666
    volumes:
      - ./data:/opt/perforce
    restart: unless-stopped
```

### Post-install configuration

Helix Core Server does not create a user by default. You will want to connect to the container's shell and run the following to create your first user:

```
p4 user -f <username>
```

Once that's done, login using [P4Admin](https://www.perforce.com/downloads/administration-tool) and enter your server URL (e.g. `ssl:localhost:1666` and your username. Once that's done, it will ask you if you want to be the sole super-user. Click **Yes**, then restart P4Admin, it should reconnect to the server and you'll see your server info and be able to manage it now.

## DO NOT UPGRADE THE SERVER IN-PLACE EVER
Please follow the [Perforce instructions](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.upgrade.html) and then start the container. I am not responsible for any loss of data that may occur, and you should **always** have proper backups.
