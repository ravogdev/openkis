# Database image of a regional site, with its data: the official MariaDB image
# plus the SQL that fills an empty volume on its first start. Built by
# build.sh, which puts the files in initdb/; see README.md. The image holds
# the site's data (users, reserved caves): keep it local or in a private
# registry, never on a public one.
ARG MARIADB_IMAGE=mariadb:11.4
FROM ${MARIADB_IMAGE}
COPY initdb/ /docker-entrypoint-initdb.d/
LABEL org.opencontainers.image.title="OpenKIS regional database"
