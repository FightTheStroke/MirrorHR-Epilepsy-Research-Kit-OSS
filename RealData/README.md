# MirrorHR Real Data Samples

This directory contains anonymized real-world data samples collected through the MirrorHR application to support scientific research on epilepsy. The data provides valuable insights into seizure patterns, symptoms, and correlations that can help advance research on epilepsy management and seizure reduction.

## Contents

- `ReadDataBPMSymptoms.zip.part*`: Multiple parts of a comprehensive archive containing exported data including heart rate patterns and symptom logs. Due to GitHub file size limitations, the file has been split into parts.
  - To reconstruct the complete file, run the included `reconstruct_zip.sh` script.
- `Sample/`: A directory containing a subset of data for a single anonymized user.
  - `DFA10208-BD0C-423E-88B7-CEAB04C312E0/`: Individual JSON files containing the user's health data exports, including heart rate readings and seizure events.
  - `CSVExportSymptoms.csv`: CSV file containing symptom events for the sample user.
  - `UserEvents.csv`: Extended event data including seizure references, high heart rate events, and potential seizure patterns with additional context.

## Data Structure

### CSVExportSymptoms.csv

The main CSV file contains event data with the following structure:
- `UserId`: Anonymous identifier for the user
- `Event`: Type of health event identified (e.g., `seizure_reference`, `high_bpm_detected`, `potential_seizure_pattern`)
- `TimeStamp`: Date and time when the event occurred

### UserEvents.csv (Extended Data)

The UserEvents.csv file provides more detailed information about the events with additional columns:
- `UserId`: Anonymous identifier for the user
- `Event`: Type of health event identified
- `TimeStamp`: Date and time when the event occurred
- `Value`: Relevant value for the event (e.g., max BPM, BPM change)
- `Notes`: Additional information including the source file

The sample user data contains:
- 111 files with seizure references
- 2,432 high heart rate (BPM > 120) events
- 81 potential seizure patterns identified by rapid heart rate changes (>40 BPM change in short period)

### JSON Data Files

The JSON files in the user directory contain detailed health metrics including:
- Heart rate data (BPM) sampled at regular intervals
- Timestamps for each reading
- Health events correlated with heart rate changes

## Research Applications

This data can be used for various research purposes:
- Identifying patterns preceding seizures
- Analyzing effectiveness of interventions
- Studying correlations between heart rate patterns and seizure occurrence
- Developing predictive models for seizure risk
- Testing algorithms for automatic seizure detection

## Usage Guidelines

1. This data is provided solely for research purposes aimed at reducing the number and severity of epileptic seizures.
2. All data has been anonymized to protect user privacy.
3. When using this data in publications or research, you must:
   - Properly cite MirrorHR and FightTheStroke Foundation
   - Include the following attribution: "Data provided by MirrorHR, developed by FightTheStroke Foundation (www.fightthestroke.org)"
   - Notify FightTheStroke Foundation about your research prior to publication by emailing [info@fightthestroke.org](mailto:info@fightthestroke.org)
4. All research or studies built using this data must be communicated to [info@fightthestroke.org](mailto:info@fightthestroke.org).
5. Submit your publication details to our research tracking system as described in the [ResearchTracking](../ResearchTracking/) directory.

## Citation Format

When citing this data in academic publications, please use the following format:

```
FightTheStroke Foundation. (YEAR). MirrorHR Epilepsy Research Data. Retrieved from https://github.com/FightTheStroke/MirrorHR-Epilepsy-Research-Kit-OSS
```

## Additional Data Access

Researchers interested in accessing more comprehensive datasets for scientific research should contact [info@fightthestroke.org](mailto:info@fightthestroke.org) to discuss collaboration opportunities.

Together, we can work toward more effective methods to reduce epileptic seizures and improve quality of life for those affected by epilepsy. 