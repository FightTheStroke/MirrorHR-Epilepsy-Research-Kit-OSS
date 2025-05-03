#!/usr/bin/env python3
"""
Script to analyze and filter MirrorHR symptom data for seizure records
and filter to a specific user ID.
"""

import csv
import os
import json
import sys
from datetime import datetime

# Constants
TARGET_USER_ID = "DFA10208-BD0C-423E-88B7-CEAB04C312E0"
INPUT_CSV = "RealData/Sample/CSVExportSymptoms.csv"
OUTPUT_CSV = "RealData/Sample/FilteredSymptoms.csv"
USER_EVENTS_CSV = "RealData/Sample/UserEvents.csv"
USER_DIR = f"RealData/Sample/{TARGET_USER_ID}"

def analyze_csv():
    """Analyze the CSV file for seizure records and filter to specific user."""
    print(f"Analyzing {INPUT_CSV} for seizure data...")
    
    seizure_count = 0
    total_rows = 0
    user_rows = 0
    user_seizure_rows = 0
    
    try:
        with open(INPUT_CSV, 'r', encoding='utf-8') as infile:
            # Read first few rows to determine CSV structure
            reader = csv.reader(infile)
            header = next(reader)
            
            # Find column indices
            try:
                user_id_col = header.index("UserId")
                print(f"UserId column found at index {user_id_col}")
            except ValueError:
                print("Error: UserId column not found in CSV header")
                return
            
            # Rewind and begin processing the whole file
            infile.seek(0)
            reader = csv.reader(infile)
            header = next(reader)  # Skip header row
            
            # Open output file for writing
            with open(OUTPUT_CSV, 'w', newline='', encoding='utf-8') as outfile:
                writer = csv.writer(outfile)
                writer.writerow(header)  # Write header
                
                # Process each row
                for row in reader:
                    total_rows += 1
                    
                    # Skip rows that are too short
                    if len(row) < len(header):
                        continue
                    
                    # Check if any seizure indicators exist in the row
                    has_seizure = False
                    if len(row) > 1 and "seizure" in row[1].lower():
                        has_seizure = True
                        seizure_count += 1
                    
                    # Check if this row belongs to our target user
                    if user_id_col < len(row) and row[user_id_col] == TARGET_USER_ID:
                        user_rows += 1
                        
                        # Write user rows to output
                        writer.writerow(row)
                        
                        # Count user's seizure records
                        if has_seizure:
                            user_seizure_rows += 1
    
    except FileNotFoundError:
        print(f"Error: File {INPUT_CSV} not found")
        return
    except Exception as e:
        print(f"Error processing CSV: {str(e)}")
        return
    
    # Report statistics
    print("\nCSV Analysis Complete")
    print(f"Total rows processed: {total_rows}")
    print(f"Total seizure records found: {seizure_count}")
    print(f"Records for user {TARGET_USER_ID}: {user_rows}")
    print(f"Seizure records for user {TARGET_USER_ID}: {user_seizure_rows}")
    print(f"Filtered data saved to {OUTPUT_CSV}")

def check_json_for_events():
    """Check the user's JSON files for health events and extract to CSV."""
    print(f"\nChecking JSON files for events in user {TARGET_USER_ID}...")
    
    # Check if user directory exists
    if not os.path.exists(USER_DIR):
        print(f"Error: User directory {USER_DIR} not found")
        return
    
    json_files = [f for f in os.listdir(USER_DIR) if f.endswith('.json')]
    
    # Set up CSV output
    with open(USER_EVENTS_CSV, 'w', newline='', encoding='utf-8') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(["UserId", "Event", "TimeStamp", "Value", "Notes"])
        
        seizure_files = 0
        seizure_count = 0
        high_bpm_count = 0
        event_count = 0
        pattern_count = 0
        
        # Process each JSON file
        for json_file in json_files:
            try:
                with open(os.path.join(USER_DIR, json_file), 'r', encoding='utf-8') as f:
                    try:
                        data = json.load(f)
                        file_has_seizure = False
                        file_high_bpm = False
                        
                        # Check for events in the data
                        if "DataSeries" in data:
                            # Look for rapid BPM changes as potential seizure patterns
                            if len(data["DataSeries"]) > 20:
                                bpm_values = [entry.get("bpm", 0) for entry in data["DataSeries"] if "bpm" in entry]
                                if bpm_values:
                                    # Check for high heart rates
                                    high_bpm_entries = [bpm for bpm in bpm_values if bpm > 120]
                                    if high_bpm_entries:
                                        file_high_bpm = True
                                        high_bpm_count += len(high_bpm_entries)
                                        timestamp = data["DataSeries"][0].get("date", "unknown")
                                        writer.writerow([
                                            TARGET_USER_ID,
                                            "high_bpm_detected",
                                            timestamp,
                                            max(high_bpm_entries),
                                            f"File: {json_file}"
                                        ])
                                        event_count += 1
                                    
                                    # Check for rapid changes (potential seizure patterns)
                                    for i in range(len(bpm_values) - 10):
                                        window = bpm_values[i:i+10]
                                        if max(window) - min(window) > 40:  # Significant change in 10 readings
                                            pattern_count += 1
                                            timestamp = data["DataSeries"][i].get("date", "unknown")
                                            writer.writerow([
                                                TARGET_USER_ID,
                                                "potential_seizure_pattern",
                                                timestamp,
                                                f"BPM change: {max(window) - min(window)}",
                                                f"File: {json_file}"
                                            ])
                                            event_count += 1
                                            break
                        
                        # Check for seizure keywords in the file
                        content = str(data).lower()
                        if "seizure" in content or "convuls" in content or "epilep" in content:
                            file_has_seizure = True
                            seizure_count += 1
                            
                            # Extract any timestamp or date from the file
                            timestamp = None
                            if "date" in content or "timestamp" in content:
                                if "DataSeries" in data and len(data["DataSeries"]) > 0:
                                    timestamp = data["DataSeries"][0].get("date", "unknown")
                                elif isinstance(data, dict):
                                    for key in data:
                                        if "date" in str(key).lower() or "time" in str(key).lower():
                                            timestamp = data[key]
                                            break
                            
                            if timestamp is None:
                                # Extract date from filename
                                parts = json_file.split('_')
                                if len(parts) > 1:
                                    timestamp = parts[1].replace('-', '/')
                            
                            writer.writerow([
                                TARGET_USER_ID,
                                "seizure_reference",
                                timestamp or "unknown",
                                "1",
                                f"File: {json_file}"
                            ])
                            event_count += 1
                        
                        if file_has_seizure:
                            seizure_files += 1
                            print(f"  - Found seizure reference in {json_file}")
                    
                    except json.JSONDecodeError:
                        print(f"Error: Could not parse {json_file} as JSON")
                
            except Exception as e:
                print(f"Error processing {json_file}: {str(e)}")
        
        print(f"\nJSON Analysis Complete")
        print(f"Files containing seizure references: {seizure_files} out of {len(json_files)}")
        print(f"Total seizure references found: {seizure_count}")
        print(f"High BPM events detected: {high_bpm_count}")
        print(f"Potential seizure patterns detected: {pattern_count}")
        print(f"Total events extracted: {event_count}")
        print(f"User events saved to {USER_EVENTS_CSV}")

if __name__ == "__main__":
    print("MirrorHR Seizure Data Analyzer")
    print("==============================")
    analyze_csv()
    check_json_for_events()
    print("\nDone!") 