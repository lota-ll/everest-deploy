# ============================================================================
# EVerest Dockerfile for OCPP 1.6
# ============================================================================

ARG EVEREST_IMAGE_TAG=0.0.23
FROM ghcr.io/everest/everest-demo/manager:${EVEREST_IMAGE_TAG}

WORKDIR /workspace

# Install http-server for viewing OCPP logs
RUN npm i -g http-server
EXPOSE 8888

# Copy start script
COPY ./start.sh /tmp/start.sh
RUN chmod +x /tmp/start.sh

ENTRYPOINT ["/tmp/start.sh"]
