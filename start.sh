#!/bin/sh
# ============================================================================
# EVerest Start Script for OCPP 1.6
# ============================================================================

# Run entrypoint
/entrypoint.sh

# Start HTTP server for OCPP logs on port 8888
http-server /tmp/everest_ocpp_logs -p 8888 &

# For OCPP 1.6
if [ "$OCPP_VERSION" = "one" ]; then
    chmod +x /ext/build/run-scripts/run-sil-ocpp.sh
    
    # Update CSMS URL in config
    sed -i "0,/127.0.0.1:8180\/steve\/websocket\/CentralSystemService\// s|127.0.0.1:8180/steve/websocket/CentralSystemService/|${EVEREST_TARGET_URL}|" /ext/dist/share/everest/modules/OCPP/config-docker.json
    
    # Start EVerest with OCPP 1.6
    /ext/build/run-scripts/run-sil-ocpp.sh
fi

# For OCPP 2.0.1 (not used in this deployment)
if [ "$OCPP_VERSION" = "two" ]; then
    apt-get update && apt-get install -y sqlite3
    sqlite3 /ext/dist/share/everest/modules/OCPP201/device_model_storage.db \
            "UPDATE VARIABLE_ATTRIBUTE \
            SET value = '[{\"configurationSlot\": 1, \"connectionData\": {\"messageTimeout\": 30, \"ocppCsmsUrl\": \"$EVEREST_TARGET_URL\", \"ocppInterface\": \"Wired0\", \"ocppTransport\": \"JSON\", \"ocppVersion\": \"OCPP20\", \"securityProfile\": 1}},{\"configurationSlot\": 2, \"connectionData\": {\"messageTimeout\": 30, \"ocppCsmsUrl\": \"$EVEREST_TARGET_URL\", \"ocppInterface\": \"Wired0\", \"ocppTransport\": \"JSON\", \"ocppVersion\": \"OCPP20\", \"securityProfile\": 1}}]' \
            WHERE \
            variable_Id IN ( \
            SELECT id FROM VARIABLE \
            WHERE name = 'NetworkConnectionProfiles' \
            );"
    
    rm -f /ext/dist/share/everest/modules/OCPP201/component_config/custom/EVSE_2.json
    rm -f /ext/dist/share/everest/modules/OCPP201/component_config/custom/Connector_2_1.json
    chmod +x /ext/build/run-scripts/run-sil-ocpp201-pnc.sh
    /ext/build/run-scripts/run-sil-ocpp201-pnc.sh
fi
