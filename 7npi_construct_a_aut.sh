#!/bin/bash

# Data Model for Automated Mobile App Tracker

# Configuration variables
APP_NAME="MyMobileApp"
TRACKING_INTERVAL=60 # in seconds
DATABASE_FILE="app_tracker.db"

# Table structure for app usage data
DECLARE -a TABLE_STRUCTURE=(
  "CREATE TABLE IF NOT EXISTS app_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    app_name TEXT NOT NULL,
    usage_start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usage_end_time TIMESTAMP,
    duration INTEGER,
    device_id TEXT NOT NULL,
    user_id TEXT NOT NULL
  );"
)

# Function to track app usage
function track_app_usage() {
  # Get current timestamp
  curr_timestamp=$(date +%s)

  # Get app usage duration
  usage_duration=$((curr_timestamp - $(pgrep -f "$APP_NAME" | xargs -I {} date -r /proc/{}/start %s)))

  # Insert usage data into database
  echo "INSERT INTO app_usage (app_name, usage_start_time, usage_end_time, duration, device_id, user_id) VALUES ('$APP_NAME', $curr_timestamp, $curr_timestamp, $usage_duration, '$DEVICE_ID', '$USER_ID');" >> $DATABASE_FILE
}

# Function to periodically track app usage
function periodic_tracking() {
  while true; do
    track_app_usage
    sleep $TRACKING_INTERVAL
  done
}

# Main function
function main() {
  # Create database if doesn't exist
  if [ ! -f "$DATABASE_FILE" ]; then
    echo "${TABLE_STRUCTURE[0]}" | sqlite3 $DATABASE_FILE
  fi

  # Start periodic tracking
  periodic_tracking
}

# Run the main function
main