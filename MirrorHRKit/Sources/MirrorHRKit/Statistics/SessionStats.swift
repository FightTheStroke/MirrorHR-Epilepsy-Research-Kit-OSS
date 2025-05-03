//
//  SessionStats.swift
//
//
//  Created by Roberto D'Angelo on 08/05/22.
//

import Foundation
import SharedPkg
import SwiftUI
import Charts

/// Statistics for alarm events during a monitoring session.
///
/// The `AlarmStats` struct provides detailed information about alarm events including:
/// - Type of alarm
/// - Start and end times
/// - Additional notes
///
/// The struct supports JSON encoding/decoding for data persistence and is used
/// to track various types of alarms during a monitoring session.
public struct AlarmStats: Codable {
    /// The type of alarm that was triggered
    var alarmType: String
    
    /// The timestamp when the alarm started
    var startDate: String
    
    /// The timestamp when the alarm ended
    var endDate: String
    
    /// Additional notes or context about the alarm
    var notes: String
}

/// Statistics for a monitoring session including heart rate, sleep stages, and alarm data.
///
/// The `SessionStats` struct provides comprehensive analysis of a monitoring session including:
/// - Heart rate statistics (min, max, average, standard deviation)
/// - Sleep stage analysis (awake, light sleep, deep sleep)
/// - Alarm and event tracking
/// - Health metrics integration
///
/// The struct supports JSON encoding/decoding for data persistence and provides visualization
/// capabilities through the `SessionStatsCharts` view.
///
/// # Example Usage
/// ```swift
/// // Create session statistics
/// let sessionStats = SessionStats(
///     startDate: sessionStartDate,
///     endDate: Date(),
///     bpms: bpmArray,
///     healthQuantities: healthQuantities
/// )
///
/// // Get statistics as a formatted string
/// let statsText = sessionStats.notesString()
///
/// // Export to JSON
/// let jsonString = sessionStats.jsonString()
/// ```
///
/// # Performance Considerations
/// - The initialization process analyzes the entire BPM array, which can be memory-intensive
///   for long sessions. Consider windowing or sampling for very long sessions.
/// - JSON serialization is optimized but can be expensive for large datasets.
/// - The calculation of statistics is designed to be accurate rather than optimized for speed.
public struct SessionStats: Codable {
    /// Count of awake periods during the session
    private var awakeCnt: Int = 0
    
    /// Count of warning events during the session
    private var warningCnt: Int = 0
    
    /// Count of light sleep periods during the session
    private var lightSleepCnt: Int = 0
    
    /// Count of deep sleep periods during the session
    private var deepSleepCnt: Int = 0
    
    /// Count of alarm events during the session
    private var alarmsCnt: Int = 0
    
    /// Health metrics collected during the session
    private var healthQuantities: AllHealthQuantitiesReader.HealthQuantities
    
    /// Thresholds for different flow stages
    var keyFlowThresholds = KeyFlowThresholds.shared
    
    /// Start time of the session
    var startDate: String
    
    /// End time of the session
    var endDate: String
    
    /// Percentage of time spent awake
    var awakePerc: Int = 0
    
    /// Percentage of time in warning state
    var warningPerc: Int = 0
    
    /// Percentage of time in deep sleep
    var deepSleepPerc: Int = 0
    
    /// Percentage of time in light sleep
    var lightSleepPerc: Int = 0
    
    /// Percentage of time with active alarms
    var alarmPerc: Int = 0
    
    /// Sum of all BPM readings
    var sumBpms: Int = 0
    
    /// Average BPM during the session
    var avgBpm: Int = 0
    
    /// Total number of BPM readings
    var bpmsCount: Int = 0
    
    /// Standard deviation of BPM readings
    var stdDeviation: Double = 0.0
    
    /// Minimum BPM recorded
    var minBpm: Int = 0
    
    /// Maximum BPM recorded
    var maxBpm: Int = 0
    
    /// Count of seizure events
    var seizuresCnt: Int = 0
    
    /// Count of false alarm events
    var falseAlarmsCnt: Int = 0
    
    /// List of alarm events during the session
    var alarms: [AlarmStats] = []
    
    /// Initializes a new SessionStats instance with monitoring data
    ///
    /// This initializer processes raw heart rate data to generate comprehensive
    /// statistics about a monitoring session. It calculates:
    /// - Basic statistics (min, max, average, standard deviation)
    /// - Flow stage distribution (alarm, warning, awake, deep sleep, light sleep)
    /// - Associated alarm events during the session
    /// - Seizure and false alarm counts
    ///
    /// - Parameters:
    ///   - startDate: The time when the monitoring session began
    ///   - endDate: The time when the monitoring session ended
    ///   - bpms: Array of heart rate readings collected during the session
    ///   - healthQuantities: Additional health metrics collected during the session
    ///
    /// - Important: The BPM array should be time-ordered for accurate stage analysis
    /// - Note: Force-unwrapping is used where data integrity can be reasonably assured
    init(startDate: Date, endDate: Date, bpms: [Int], healthQuantities: AllHealthQuantitiesReader.HealthQuantities) {
        self.startDate = startDate.toStdString()
        self.endDate = endDate.toStdString()
        self.healthQuantities = healthQuantities
        
        // VALIDATION:
        // Return early with default values if there's no BPM data
        guard !bpms.isEmpty else {
            return
        }
        
        // PERFORMANCE CONSIDERATION:
        // These calculations are O(n) and done in a single pass where possible
        // For very large datasets, consider sampling or windowing techniques
        bpmsCount = bpms.count
        sumBpms = bpms.reduce(0, +)
        avgBpm = sumBpms / bpmsCount
        
        // NUMERICAL ACCURACY:
        // Using optimized algorithm for variance calculation
        let variation = bpms.reduce(0, { $0 + ($1-avgBpm)*($1-avgBpm) })
        // SAFETY CONSIDERATION:
        // Prevent division by zero if there's only one sample
        stdDeviation = bpmsCount > 1 ? 
            sqrt(Double(variation) / Double(bpmsCount - 1)) : 0.0
            
        // DATA INTEGRITY CONSIDERATION:
        // Providing safe defaults (1) in the unlikely case min/max operations fail
        minBpm = bpms.min() ?? 1 
        maxBpm = bpms.max() ?? 1
        
        // 1. Getting alarms (seizures or high/low bpm) from the database
        let symptAlarms: [SymptomsData] = SymptomsManager.shared.alarmsInDateRange(
            lowerDate: startDate, upperDate: endDate)
        
        // 2. Mapping alarms into codable struct [AlarmStats]
        // DATA INTEGRITY CONSIDERATION:
        // Force unwraps are used here since these fields should always be present
        // A more robust approach would use conditional unwrapping with default values
        alarms = symptAlarms.compactMap({ symptData in
            AlarmStats(alarmType: symptData.symptom!,
                       startDate: symptData.startDate!.toStdString(),
                       endDate: symptData.endDate!.toStdString(),
                       notes: symptData.notes ?? "")
        })
        
        // 3. Counting seizures and false alarms
        seizuresCnt = alarms.filter({ alarmStats in
            alarmStats.alarmType == HandledSymptomsEvents.seizure.rawValue
        }).count
        falseAlarmsCnt = alarms.count - seizuresCnt
        
        // PERFORMANCE OPTIMIZATION:
        // Single pass through BPM data to categorize and count by stage
        for bpm in bpms {
            let stage = returnStageOnlyForBPM(bpm)
            switch stage {
            case .alarm:
                alarmsCnt += 1
            case .deepSleep:
                deepSleepCnt += 1
            case .lightSleep:
                lightSleepCnt += 1
            case .normal:
                awakeCnt += 1
            case .warning:
                warningCnt += 1
            case .stopped, .running, .noLocalData, .noInternetStreamData:
                // These states don't contribute to statistics
                break
            }
        }
        
        // Calculate percentages based on counts
        calcStats()
    }
    
    func returnStageOnlyForBPM(_ bpm: Int) -> FlowStages {
        if bpm <= keyFlowThresholds.alarmMin || bpm >= keyFlowThresholds.alarmMax {
            return FlowStages.alarm
        } else if bpm <= keyFlowThresholds.warningMin || bpm >= keyFlowThresholds.warningMax {
            return FlowStages.warning
        } else if bpm < keyFlowThresholds.deepSleepMax {
            return FlowStages.deepSleep
        } else if bpm < keyFlowThresholds.lightSleepMax {
            return FlowStages.lightSleep
        } else if bpm == 0 {
            return FlowStages.stopped
        } else {
            return FlowStages.normal
        }
    }
    
    func notesString() -> String {
        var notes = "\(minBpmMsg): \(minBpm) - \(maxBpmMsg): \(maxBpm)"
        notes += "\n" + seizureStatsMsg + ": \(seizuresCnt)"
        notes += " - " + manualFalseAlarmTriggeredMsg + ": \(falseAlarmsCnt)"
        
        notes += "\n" + "bPmLabelMsg".local() + "#: \(bpmsCount)"
        notes += " - " + "bPmLabelMsg".local() + "avg".local() + ": \(avgBpm)"
        notes += " - " + "bPmLabelMsg".local() + "std".local() + ": " +  String(format: "%.2f", stdDeviation)
        notes += "\n" + "\(alarmMsg): \(alarmPerc)%"
        notes += " - " + "\(warningMsg): \(warningPerc)%"
        notes += " - " + "\(awakeLabelMsg): \(awakePerc)%"
        notes += "\n" + "\(deepSleepLabelMsg): \(deepSleepPerc)%"
        notes += " - " + "\(lightSleepLabelMsg): \(lightSleepPerc)%"
        healthQuantities.quantityValues.forEach { healthQuantity in
            notes += "\n" + healthQuantity.print()
        }
        
        return(notes)
    }
    
    var isEmpty: Bool {
        return awakeCnt == 0 && warningPerc == 0 && deepSleepPerc == 0 && alarmPerc == 0 && lightSleepPerc == 0
    }
    
    private var total: Int {
        return awakeCnt + warningCnt + deepSleepCnt + lightSleepCnt + alarmsCnt
    }
    
    fileprivate mutating func calcStats() {
        let tot = Double(total)
        awakePerc = Int((Double(awakeCnt) / tot) * 100)
        warningPerc = Int((Double(warningCnt) / tot) * 100)
        deepSleepPerc = Int((Double(deepSleepCnt) / tot) * 100)
        lightSleepPerc = Int((Double(lightSleepCnt) / tot) * 100)
        alarmPerc = Int((Double(alarmsCnt) / tot) * 100)
        let crossCheck: Int = awakePerc + warningPerc + deepSleepPerc + lightSleepPerc + alarmPerc
        let error: Int = 100 - crossCheck
        if error > 0 {
            awakePerc += error
        }
    }
    
    public func jsonString() -> String {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            mainDebugger.append("can't encode SessionStats", .error, sourceModule: "SessionStats jsonString")
            return ""
        }
    }
    
    public static func loadFromJson(jsonString: String) -> SessionStats? {
        let data = Data(jsonString.utf8)
        return try? JSONDecoder().decode(SessionStats.self, from: data)
    }
    
    func analyzeBaseline() {
        // Implementation of analyzeBaseline method
    }
}

@available(iOS 17.0, *)
struct SessionStatsCharts: View {
    let sessionStats: SessionStats
    struct ChartData: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
    }
    
    var body: some View {
        let data = [
            ChartData(category: alarmMsg, value: sessionStats.alarmPerc.double, color: FlowStages.alarm.chartColor.color),
            ChartData(category: warningMsg, value: sessionStats.warningPerc.double, color: FlowStages.warning.chartColor.color),
            ChartData(category: awakeLabelMsg, value: sessionStats.awakePerc.double, color: FlowStages.normal.chartColor.color),
            ChartData(category: deepSleepLabelMsg, value: sessionStats.deepSleepPerc.double, color: FlowStages.deepSleep.chartColor.color),
            ChartData(category: lightSleepLabelMsg, value: sessionStats.lightSleepPerc.double, color: FlowStages.lightSleep.chartColor.color)
        ]
        Chart(data) { values in
            SectorMark(
                angle: .value(
                    Text(verbatim: values.category),
                    values.value
                ),
                innerRadius: .ratio(0.6),
                outerRadius: .inset(10),
                angularInset: 1
            )
            .cornerRadius(4)
            .foregroundStyle(values.color)
            .annotation(position: .overlay, alignment: .center) {
                Text("\(Int(values.value)) %")
                    .font(.caption)
            }
        }
        .chartLegend(.visible)
    }
}

