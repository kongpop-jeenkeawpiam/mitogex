#!/bin/bash

# Configuration
Path_Program=$1
APP_NAME="MitoGEx-1.0.jar"                   # Name of your JAR file
UPDATE_URL="https://www.mitogex.com/java/MitoGEx-1.0.jar" # URL for the updated JAR
VERSIONS_URL="https://www.mitogex.com/versions.txt"     # URL for the unified versions file
DB_BASE_URL="https://www.mitogex.com/database/annovar/"  # Base URL for the database directory
SCRIPTS_ZIP_URL="https://www.mitogex.com/scripts/scripts.zip" # URL for the updated scripts.zip
LOCAL_VERSIONS_FILE="$1/local_versions.txt"           # Unified local version file
LOCAL_DB_DIR="$1/Software/annovar/humandb"            # Directory containing database files
TEMP_DB_DIR="$1/Software/annovar/temp_humandb"        # Temporary directory for new database files
LOG_FILE="$1/update.log"                              # Log file for the update process
SCRIPTS_DIR="$1/Software/scripts"                     # Directory containing scripts

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Initialize local versions file if it doesn't exist
if [ ! -f "$LOCAL_VERSIONS_FILE" ]; then
    echo "APP_VERSION=1.0" > "$LOCAL_VERSIONS_FILE"
    echo "MitImpact=313" >> "$LOCAL_VERSIONS_FILE"
    echo "SCRIPTS_VERSION=1.0" >> "$LOCAL_VERSIONS_FILE"  # Add scripts version tracking
    log "Initialized local versions file with APP_VERSION=1.0.0, MitImpact_VERSION=313, and SCRIPTS_VERSION=1.0."
fi

# Read local versions
LOCAL_APP_VERSION=$(grep 'APP_VERSION' "$LOCAL_VERSIONS_FILE" | cut -d '=' -f2)
LOCAL_DB_VERSION=$(grep 'MitImpact' "$LOCAL_VERSIONS_FILE" | cut -d '=' -f2)
LOCAL_SCRIPTS_VERSION=$(grep 'SCRIPTS_VERSION' "$LOCAL_VERSIONS_FILE" | cut -d '=' -f2)

# Step 1: Fetch latest versions from server
log "Fetching latest versions from server..."
LATEST_VERSIONS=$(curl -s $VERSIONS_URL)
LATEST_APP_VERSION=$(echo "$LATEST_VERSIONS" | grep 'APP_VERSION' | cut -d '=' -f2)
LATEST_DB_VERSION=$(echo "$LATEST_VERSIONS" | grep 'MitImpact' | cut -d '=' -f2)
LATEST_SCRIPTS_VERSION=$(echo "$LATEST_VERSIONS" | grep 'SCRIPTS_VERSION' | cut -d '=' -f2)

# Step 2: Check for application updates
log "Checking for application updates..."
if [ "$LATEST_APP_VERSION" != "$LOCAL_APP_VERSION" ]; then
    log "Application update available: $LATEST_APP_VERSION. Current version: $LOCAL_APP_VERSION."
    log "Downloading application update..."
    curl -o "$Path_Program/MitoGEx-1.0.jar" $UPDATE_URL
    if [ $? -ne 0 ]; then
        log "Failed to download the application update. Exiting."
        exit 2
    fi

    log "Stopping the current application..."
    pkill -f "java -jar $APP_NAME"
    sleep 2

    log "Replacing the old application with the new version..."
    mv -f "$Path_Program/MitoGEx-1.0.jar" "$Path_Program/$APP_NAME"

    log "Updating local APP_VERSION to $LATEST_APP_VERSION."
    sed -i "s/^APP_VERSION=.*/APP_VERSION=$LATEST_APP_VERSION/" "$LOCAL_VERSIONS_FILE"

    log "Application update to version $LATEST_APP_VERSION completed successfully."
else
    log "Application is up to date."
fi

# Step 3: Check for database updates
log "Checking for database updates..."
if [ "$LATEST_DB_VERSION" != "$LOCAL_DB_VERSION" ]; then
    log "Database update available: $LATEST_DB_VERSION. Current version: $LOCAL_DB_VERSION."
    log "Downloading MitImpact database file for version $LATEST_DB_VERSION..."

    # Create a temporary directory for the new database file
    mkdir -p "$TEMP_DB_DIR"

    # Define the specific MitImpact database file to download
    MITIMPACT_FILE="hg38_MitImpact${LATEST_DB_VERSION}.txt"

    # Download the file
    FILE_URL="${DB_BASE_URL}${MITIMPACT_FILE}"
    curl -o "$TEMP_DB_DIR/$MITIMPACT_FILE" "$FILE_URL"
    if [ $? -ne 0 ]; then
        log "Failed to download $MITIMPACT_FILE. Exiting."
        exit 3
    fi
    log "Downloaded $MITIMPACT_FILE successfully."

    # Replace the old MitImpact file with the new one
    log "Replacing old MitImpact file with the new version..."
    mv -f "$TEMP_DB_DIR/$MITIMPACT_FILE" "$LOCAL_DB_DIR/$MITIMPACT_FILE"

    # Update the local version file
    log "Updating local MitImpact version to $LATEST_DB_VERSION."
    sed -i "s/^MitImpact=.*/MitImpact=$LATEST_DB_VERSION/" "$LOCAL_VERSIONS_FILE"

    log "MitImpact database update to version $LATEST_DB_VERSION completed successfully."
else
    log "No database updates available."
fi

# Step 4: Check for script updates
log "Checking for script updates..."
if [ "$LATEST_SCRIPTS_VERSION" != "$LOCAL_SCRIPTS_VERSION" ]; then
    log "Script update available: $LATEST_SCRIPTS_VERSION. Current version: $LOCAL_SCRIPTS_VERSION."
    log "Downloading script update..."

    # Download the updated scripts.zip
    curl -o "$SCRIPTS_DIR/scripts.zip" $SCRIPTS_ZIP_URL
    if [ $? -ne 0 ]; then
        log "Failed to download scripts.zip. Exiting."
        exit 4
    fi

    log "Unzipping the new scripts..."
    unzip -o "$SCRIPTS_DIR/scripts.zip" -d "$SCRIPTS_DIR/"
    if [ $? -ne 0 ]; then
        log "Failed to unzip the scripts. Exiting."
        exit 5
    fi

    log "Setting executable permissions on scripts..."
    chmod +x "$SCRIPTS_DIR"/*.sh

    # Update the local version file
    log "Updating local SCRIPTS_VERSION to $LATEST_SCRIPTS_VERSION."
    sed -i "s/^SCRIPTS_VERSION=.*/SCRIPTS_VERSION=$LATEST_SCRIPTS_VERSION/" "$LOCAL_VERSIONS_FILE"

    log "Script update to version $LATEST_SCRIPTS_VERSION completed successfully."
else
    log "Scripts are up to date."
fi

log "Update process completed."
exit 0
