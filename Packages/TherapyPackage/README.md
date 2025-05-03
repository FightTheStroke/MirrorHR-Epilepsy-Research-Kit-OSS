# TherapyPackage

A comprehensive medication and therapy management system for the MirrorHR healthcare application.

## Overview

TherapyPackage provides a complete solution for managing medications, treatments, and therapy protocols. It enables scheduling, dosage tracking, medication history, and adherence monitoring for patients with epilepsy and other chronic conditions.

## Key Features

- **Medication Management**: Track medications, dosages, and schedules
- **Reminder System**: Generate notifications for medication times
- **Adherence Tracking**: Monitor medication compliance
- **Treatment Protocols**: Define and manage complex treatment regimens
- **History Logging**: Record medication administration history
- **Dosage Calculations**: Calculate proper dosages based on patient parameters
- **Drug Interactions**: Check for potential medication interactions
- **Medication Inventory**: Track medication supplies and refill needs
- **SwiftUI Interface**: Fully native SwiftUI user interface components

## Architecture

The package is organized into several key components:

```
TherapyPackage/
├── Models/                   # Core data models
│   ├── Medication.swift      # Medication definitions
│   ├── Dose.swift            # Dosage calculations and timing
│   ├── Protocol.swift        # Treatment protocol definitions
│   └── Adherence.swift       # Compliance tracking
├── Managers/                 # Business logic managers
│   ├── TherapyManager.swift  # Main coordination manager
│   ├── ReminderManager.swift # Scheduling and reminders
│   └── InventoryManager.swift # Medication inventory tracking
├── Views/                    # User interface components
│   ├── MedicationView.swift  # Medication details and scheduling
│   ├── DoseHistoryView.swift # History of medication administration
│   └── AdherenceView.swift   # Compliance visualization
└── Utilities/                # Support functionality
    ├── DosageCalculator.swift # Calculate proper dosages
    └── InteractionChecker.swift # Check for drug interactions
```

## Usage

### Basic Medication Management

```swift
import TherapyPackage
import SwiftUI

struct MedicationManagementView: View {
    @ObservedObject var therapyManager = TherapyManager.shared
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(therapyManager.medications) { medication in
                    NavigationLink(destination: MedicationDetailView(medication: medication)) {
                        MedicationRowView(medication: medication)
                    }
                }
                .onDelete(perform: deleteMedication)
            }
            .navigationTitle("Medications")
            .toolbar {
                Button("Add Medication") {
                    showingAddMedication = true
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView()
            }
        }
    }
    
    func deleteMedication(at offsets: IndexSet) {
        for index in offsets {
            therapyManager.removeMedication(therapyManager.medications[index])
        }
    }
}
```

### Setting Up Medication Reminders

```swift
// Create a new medication
let medication = Medication(
    name: "Levetiracetam",
    dosage: 500,
    unit: "mg",
    form: .tablet,
    frequency: .twice,
    times: [Time(hour: 8, minute: 0), Time(hour: 20, minute: 0)],
    instructions: "Take with food"
)

// Add to therapy manager
TherapyManager.shared.addMedication(medication)

// Schedule reminders
ReminderManager.shared.scheduleReminders(for: medication) { success in
    if success {
        print("Reminders scheduled successfully")
    } else {
        print("Failed to schedule reminders")
    }
}
```

### Tracking Adherence

```swift
// Record medication taken
func medicationTaken(_ medication: Medication) {
    let dose = Dose(
        medication: medication, 
        timestamp: Date(),
        amount: medication.dosage,
        status: .taken
    )
    
    TherapyManager.shared.recordDose(dose)
}

// Check adherence statistics
let adherenceStats = TherapyManager.shared.getAdherenceStatistics(
    for: medication,
    startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60), // Last 30 days
    endDate: Date()
)

print("Adherence rate: \(adherenceStats.adherenceRate * 100)%")
print("Doses taken: \(adherenceStats.dosesTaken)")
print("Doses missed: \(adherenceStats.dosesMissed)")
```

### Managing Treatment Protocols

```swift
// Define a treatment protocol
let protocol = TreatmentProtocol(
    name: "Standard Epilepsy Protocol",
    medications: [
        ProtocolMedication(medication: levetiracetam, phase: .maintenance),
        ProtocolMedication(medication: lamotrigine, phase: .titration(
            steps: [
                TitrationStep(dosage: 25, duration: 14),
                TitrationStep(dosage: 50, duration: 14),
                TitrationStep(dosage: 100, duration: 14),
                TitrationStep(dosage: 200, duration: 0)
            ]
        ))
    ],
    duration: nil // Ongoing
)

// Apply protocol to patient
TherapyManager.shared.applyProtocol(protocol)
```

## Performance Considerations

TherapyPackage is optimized for performance:

- **Efficient Storage**: CoreData with optimized queries for medication data
- **Background Processing**: Reminder scheduling happens in the background
- **Batched Operations**: Bulk operations for medication imports/exports
- **Memory Management**: Careful resource management for long-term performance
- **Scheduling Optimization**: Smart scheduling to reduce notification overhead

## Thread Safety

The package implements thread safety through:

- **Serial Queue Operations**: Core functions execute on dedicated serial queues
- **Thread Confinement**: UI updates dispatched to main thread
- **Atomic Operations**: Thread-safe data modifications
- **CoreData Safety**: Proper context management for database operations

## Integration with Health Data

TherapyPackage integrates with HealthKit to provide a comprehensive health view:

```swift
// Correlate medication with health metrics
TherapyManager.shared.correlateHealthMetrics(
    medication: medication,
    metric: .heartRate,
    completion: { result in
        switch result {
        case .success(let correlation):
            print("Correlation found: \(correlation.description)")
        case .failure(let error):
            print("Failed to correlate: \(error.localizedDescription)")
        }
    }
)
```

## Requirements

- iOS 15.0+
- Swift 5.5+
- HealthKit for health data integration
- UserNotifications for medication reminders

## Integration

Add TherapyPackage to your project:

```swift
dependencies: [
    .package(url: "path/to/TherapyPackage", .branch("main"))
]

targets: [
    .target(
        name: "YourTarget", 
        dependencies: ["TherapyPackage"]
    )
]
```