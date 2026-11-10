FROM alpine:3.24.4@sha256:0f49f331d9212aff11b932863be4eb01cdf962969aa86dab7d1ee21ac6f5f52b

WORKDIR /app
COPY --chmod=0755 vibenest/bin/glance-linux-amd64 /app/glance
COPY vibenest/entrypoint.sh vibenest/glance.yml vibenest/pages.yml /app/vibenest/
COPY LICENSE /app/LICENSE

EXPOSE 8080/tcp
ENTRYPOINT ["/bin/sh", "/app/vibenest/entrypoint.sh"]
