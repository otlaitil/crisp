FROM python:3.9.1-alpine3.13

#
# Install runtime dependencies
#
# Dependency  Required by
# -------------------------
# curl        entrypoint.sh
# jq          entrypoint.sh
#
RUN apk add --no-cache \
 curl=7.74.0-r0 \
 jq=1.6-r1

COPY requirements.txt /tmp/requirements.txt
RUN pip install --requirement /tmp/requirements.txt

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
