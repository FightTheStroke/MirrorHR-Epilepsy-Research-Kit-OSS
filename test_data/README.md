# Test Data for MirrorHR

This directory contains sample data for testing and development purposes. None of this data contains real patient information - all data is synthetically generated.

## Contents

### Heart Rate Samples

- `heart_rate_normal.json`: Sample of normal heart rate pattern
- `heart_rate_exercise.json`: Sample of heart rate during exercise
- `heart_rate_seizure_pattern.json`: Synthetic heart rate pattern mimicking a seizure event

### Symptom Logs

- `symptoms_sample.json`: Various symptom log entries for testing
- `seizure_log_simple.json`: Basic seizure log entries
- `seizure_log_detailed.json`: Detailed seizure log with multiple attributes

### Video Transcripts

- `transcript_normal.txt`: Sample transcript without seizure indicators
- `transcript_with_symptoms.txt`: Transcript containing various symptom descriptions
- `transcript_multiple_languages.txt`: Transcripts in multiple languages for localization testing

## Usage

### Loading Test Data

You can load this test data in development builds using the developer menu:

1. Enable developer mode in settings (tap 10 times on version number)
2. Go to the developer menu
3. Select "Load Test Data"
4. Choose the appropriate dataset

### Programmatic Loading

```swift
func loadTestData() {
    guard let url = Bundle.main.url(forResource: "heart_rate_normal", withExtension: "json") else {
        fatalError("Could not find test data file")
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let heartRateSamples = try decoder.decode([HeartRateSample].self, from: data)
        // Use the samples for testing
    } catch {
        print("Error loading test data: \(error)")
    }
}
```

## Data Format

### Heart Rate Samples

```json
[
  {
    "timestamp": "2023-01-15T14:30:00Z",
    "value": 72,
    "source": "apple_watch"
  },
  {
    "timestamp": "2023-01-15T14:30:05Z",
    "value": 73,
    "source": "apple_watch"
  }
]
```

### Symptom Logs

```json
[
  {
    "id": "symptom-001",
    "type": "seizure",
    "subtype": "tonic_clonic",
    "startTime": "2023-01-15T15:45:00Z",
    "endTime": "2023-01-15T15:48:30Z",
    "notes": "Example seizure description",
    "severity": "severe"
  }
]
```

## Contributing Test Data

If you'd like to contribute additional test data:

1. Ensure NO real patient data is included
2. Follow the established JSON/CSV formats
3. Add clear documentation about what the data represents
4. Include the data generation methodology

## IMPORTANT NOTICE

This test data is provided for development purposes only. The patterns and values in these files are synthetic and should not be used for any medical assessment, diagnosis, or treatment decisions.

While we've attempted to create realistic data patterns for testing, they may not accurately represent real-world epilepsy events or heart rate patterns. Medical professionals should rely on clinical data and established diagnostic criteria, not these test samples.