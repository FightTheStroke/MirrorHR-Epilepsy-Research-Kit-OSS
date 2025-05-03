#!/usr/bin/env python3
"""
Script to clean the CSVExportSymptoms.csv file to contain only data for a specific user
and convert the UserEvents.csv format to match the CSVExportSymptoms.csv format.
"""

import csv
import os

# Constants
TARGET_USER_ID = "DFA10208-BD0C-423E-88B7-CEAB04C312E0"
USER_EVENTS_CSV = "RealData/Sample/UserEvents.csv"
EXPORT_SYMPTOMS_CSV = "RealData/Sample/CSVExportSymptoms.csv"
FILTERED_SYMPTOMS_CSV = "RealData/Sample/FilteredSymptoms.csv"
BACKUP_EXPORT_CSV = "RealData/Sample/CSVExportSymptoms.csv.bak"

def clean_csv():
    """Clean the CSVExportSymptoms.csv file to only include data for the target user."""
    print(f"Creating clean CSVExportSymptoms.csv with only data for user {TARGET_USER_ID}")
    
    # First, create a backup of the original file
    if os.path.exists(EXPORT_SYMPTOMS_CSV):
        print(f"Creating backup of original CSVExportSymptoms.csv")
        with open(EXPORT_SYMPTOMS_CSV, 'r', encoding='utf-8') as infile:
            with open(BACKUP_EXPORT_CSV, 'w', encoding='utf-8') as outfile:
                outfile.write(infile.read())
        print(f"Backup created as {BACKUP_EXPORT_CSV}")
    
    # Convert UserEvents.csv to the CSVExportSymptoms.csv format
    events_data = []
    try:
        with open(USER_EVENTS_CSV, 'r', encoding='utf-8') as infile:
            reader = csv.reader(infile)
            header = next(reader)  # Get header row
            
            # Check required columns
            if 'UserId' not in header or 'Event' not in header or 'TimeStamp' not in header:
                print("Error: UserEvents.csv doesn't have the required columns.")
                return
            
            user_id_col = header.index('UserId')
            event_col = header.index('Event')
            timestamp_col = header.index('TimeStamp')
            
            # Read all rows for the target user
            for row in reader:
                if len(row) > max(user_id_col, event_col, timestamp_col):
                    if row[user_id_col] == TARGET_USER_ID:
                        # Convert to CSVExportSymptoms.csv format [UserId, Event, TimeStamp]
                        events_data.append([
                            row[user_id_col],
                            row[event_col],
                            row[timestamp_col]
                        ])
        
        print(f"Found {len(events_data)} events for user {TARGET_USER_ID}")
        
        # Write the cleaned data to CSVExportSymptoms.csv
        with open(EXPORT_SYMPTOMS_CSV, 'w', newline='', encoding='utf-8') as outfile:
            writer = csv.writer(outfile)
            writer.writerow(['UserId', 'Event', 'TimeStamp'])  # Write header
            writer.writerows(events_data)
        
        print(f"Clean CSVExportSymptoms.csv created with {len(events_data)} events")
        
    except Exception as e:
        print(f"Error processing CSV: {str(e)}")
        return
    
    # Delete FilteredSymptoms.csv if it exists
    if os.path.exists(FILTERED_SYMPTOMS_CSV):
        try:
            os.remove(FILTERED_SYMPTOMS_CSV)
            print(f"Deleted {FILTERED_SYMPTOMS_CSV}")
        except Exception as e:
            print(f"Error deleting {FILTERED_SYMPTOMS_CSV}: {str(e)}")

if __name__ == "__main__":
    print("MirrorHR CSV Cleaner")
    print("====================")
    clean_csv()
    print("\nDone!") 