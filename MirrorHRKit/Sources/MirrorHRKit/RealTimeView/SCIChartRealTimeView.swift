//
//  SCIChartRealTimeView.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 28/09/2020.
//

import Combine
import SciChart
import SwiftUI
import SharedPkg

/// SwiftUI representation of SciChart surface for real-time heart rate visualization
///
/// This struct provides a bridge between SwiftUI and the SciChart native UIKit component.
/// It handles chart configuration, marker placement, and responds to parameter changes
/// to ensure the chart always reflects current user settings for threshold values.
///
/// The chart includes:
/// - Date-based X-axis for time series visualization
/// - Numeric Y-axis for heart rate values (BPM)
/// - Color-coded visualization based on heart rate zones
/// - Threshold markers for different heart rate zones (alarm, sleep, etc.)
/// - Interactive features like pinch-zoom and data inspection
///
/// - Important: This is a performance-critical component that must render efficiently
///   during real-time data updates to avoid dropped frames or delayed visualization.
struct SciChartSurfaceViewRep: UIViewRepresentable, KeyParametersSubscriber {
    /// Subscription for parameter change notifications
    var parametersSubscriber = AnyCancellable {}
    
    /// User settings for chart display preferences
    private var settings = ProfileGenericSettings.shared
    
    /// Handles parameter updates from the global parameter publisher
    func handleUpdateParams() {
        mainDebugger.append("updated parameters broadcast received")
        updateAxisMarkers()
    }

    // MARK: - SciChart Configuration

    /// The core SciChart surface component
    var sciChartSurface: SCIChartSurface
    
    /// X-axis configured for date-time visualization
    let xAxis = SCIDateAxis()
    
    /// Y-axis configured for numeric BPM values
    let yAxis = SCINumericAxis()

    // MARK: - Chart Markers
    
    /// Marker for minimum alarm threshold
    var alarmMinMarker = SCIAxisMarkerAnnotation()
    
    /// Marker for maximum alarm threshold
    var alarmMaxMarker = SCIAxisMarkerAnnotation()
    
    /// Marker for deep sleep maximum threshold
    var deepSleepMaxMarker = SCIAxisMarkerAnnotation()
    
    /// Marker for light sleep maximum threshold
    var lightSleepMaxMarker = SCIAxisMarkerAnnotation()
    
    /// Collection of all threshold markers for batch operations
    let chartMarkers: [SCIAxisMarkerAnnotation]

    init(chartSurface: SCIChartSurface, bpmDataSeries: SCIXyDataSeries) {
        sciChartSurface = chartSurface
        chartMarkers = [alarmMinMarker, alarmMaxMarker, deepSleepMaxMarker, lightSleepMaxMarker]
        customizeSciChartView(bpmDataSeries: bpmDataSeries)
        createAxisMarkers()
        if settings.chartShowMarkers {
            showAxisMarkers()
        } else {
            hideAxisMarkers()
        }
        if settings.chartShowBands {
            showBands()
        } else {
            hideBands()
        }
        sciChartSurface.renderableSeriesAreaBorderStyle = .init(thickness: 0, antiAliasing: true, strokeDashArray: nil)
        parametersSubscriber = keyParametersChanged
            .receive(on: DispatchQueue.main) // Assicurati che l'operazione venga eseguita sul main thread
            .sink(receiveValue: { [self] in
                handleUpdateParams()
            })
    }

    func makeUIView(context _: Context) -> SCIChartSurface {
        sciChartSurface
    }

    func updateUIView(_: SCIChartSurface, context _: Context) {
        sciChartSurface.backgroundColor = UIColor.systemBackground
        if settings.chartShowMarkers {
            showAxisMarkers()
        } else {
            hideAxisMarkers()
        }
        if settings.chartShowBands {
            showBands()
        } else {
            hideBands()
        }
    }

    func customizeSciChartView(bpmDataSeries: SCIXyDataSeries) {
        sciChartSurface.backgroundColor = UIColor.systemBackground
        yAxis.visibleRange = SCIDoubleRange(min: 0, max: 200)
        yAxis.autoRange = .once

        sciChartSurface.xAxes.add(items: xAxis)
        sciChartSurface.yAxes.add(items: yAxis)
        let bpmSeries = SCIFastColumnRenderableSeries()
        bpmSeries.dataSeries = bpmDataSeries
        bpmSeries.paletteProvider = BPMRealTimePAletteProvider()

        SCIUpdateSuspender.usingWith(sciChartSurface) {
            sciChartSurface.renderableSeries.add(items: bpmSeries)
        }

        let rolloverModifier = SCIRolloverModifier()
        rolloverModifier.receiveHandledEvents = true
        
//        let pinchZoomModifier = SCIPinchZoomModifier()
//        pinchZoomModifier.receiveHandledEvents = true
        
        // Add chart modifiers outside of the update suspender closure
        sciChartSurface.chartModifiers.add(items: rolloverModifier)
    }

    func createAxisMarkers() {
        let flowThresholds: KeyFlowThresholds = KISSFlowManager.shared.keyFlowThresholds
        chartMarkers.forEach { marker in
            marker.formattedLabelValueProvider = AnnotationValueProvider()
        }
        alarmMinMarker.set(y1: flowThresholds.alarmMin)
        alarmMaxMarker.set(y1: flowThresholds.alarmMax)
        deepSleepMaxMarker.set(y1: flowThresholds.deepSleepMax)
        lightSleepMaxMarker.set(y1: flowThresholds.lightSleepMax)
        alarmMinMarker.borderPen = SCISolidPenStyle(color: FlowStages.alarm.chartColor, thickness: 1)
        alarmMinMarker.backgroundBrush = SCISolidBrushStyle(color: FlowStages.alarm.chartColor)
        alarmMaxMarker.borderPen = SCISolidPenStyle(color: FlowStages.alarm.chartColor, thickness: 1)
        alarmMaxMarker.backgroundBrush = SCISolidBrushStyle(color: FlowStages.alarm.chartColor)
        deepSleepMaxMarker.borderPen = SCISolidPenStyle(color: FlowStages.deepSleep.chartColor, thickness: 1)
        deepSleepMaxMarker.backgroundBrush = SCISolidBrushStyle(color: FlowStages.deepSleep.chartColor)
        lightSleepMaxMarker.borderPen = SCISolidPenStyle(color: FlowStages.lightSleep.chartColor, thickness: 1)
        lightSleepMaxMarker.backgroundBrush = SCISolidBrushStyle(color: FlowStages.lightSleep.chartColor)
        sciChartSurface.annotations.add(items: alarmMinMarker, alarmMaxMarker, lightSleepMaxMarker, deepSleepMaxMarker)
    }

    func testSciChart(bpmDataSeries: SCIXyDataSeries) {
        bpmDataSeries.clear()
        for xLabel in 0 ..< 200 {
            bpmDataSeries.append(x: Date(), y: xLabel)
        }
        for xLabel in (1 ..< 200).reversed() {
            bpmDataSeries.append(x: Date(), y: xLabel)
        }
        sciChartSurface.zoomExtents()
    }

    func updateAxisMarkers() {
        let flowThresholds: KeyFlowThresholds = KISSFlowManager.shared.keyFlowThresholds
        alarmMinMarker.set(y1: flowThresholds.alarmMin)
        alarmMaxMarker.set(y1: flowThresholds.alarmMax)
        deepSleepMaxMarker.set(y1: flowThresholds.deepSleepMax)
        lightSleepMaxMarker.set(y1: flowThresholds.lightSleepMax)
    }

    func showBands() {
        xAxis.drawMajorBands = true
        yAxis.drawMajorBands = true
        xAxis.drawMajorGridLines = true
        xAxis.drawMinorGridLines = true
        xAxis.drawMajorTicks = true
        xAxis.drawMinorTicks = true
        xAxis.drawMajorBands = true
    }

    func hideBands() {
        xAxis.drawMajorBands = false
        xAxis.drawMajorGridLines = false
        xAxis.drawMinorGridLines = false
        xAxis.drawMajorTicks = false
        xAxis.drawMinorTicks = false

        yAxis.drawMajorBands = false
        yAxis.drawMajorGridLines = false
        yAxis.drawMinorGridLines = false
        yAxis.drawMajorTicks = false
        yAxis.drawMinorTicks = false
    }

    func showAxisMarkers() {
        chartMarkers.forEach { marker in
            marker.show()
        }
    }

    func hideAxisMarkers() {
        chartMarkers.forEach { marker in
            marker.hide()
        }
    }
}

class BPMRealTimePAletteProvider: SCIPaletteProviderBase<SCIXyRenderableSeriesBase>, ISCIStrokePaletteProvider, ISCIFillPaletteProvider {
    private var flowThresholds = KeyFlowThresholds.shared
    var kissFlowManager = KISSFlowManager.shared

    let strokeColors = SCIUnsignedIntegerValues()
    let fillColors = SCIUnsignedIntegerValues()

    required init() {
        super.init(renderableSeriesType: SCIXyRenderableSeriesBase.self)
    }

    override func update() {
        guard let renderPassData = renderableSeries?.currentRenderPassData as? SCIXyRenderPassData else {
            // Display a UIAlertController telling the user to check for an updated app..
            return
        }
        let count = renderPassData.pointsCount
        strokeColors.count = count
        fillColors.count = count

        let yValues = renderPassData.yValues
        for count in 0 ..< count {
            let value = yValues.getValueAt(count)
//            let flowStage = kissFlowManager.AnalyzeFlowForBPM(Int(value))
            let fillColor = kissFlowManager.returnColorOnlyForBPM(Int(value))

            strokeColors.set(fillColor.colorARGBCode(), at: count)
            fillColors.set(fillColor.colorARGBCode(), at: count)
        }
    }
}

// Declare custom ISCIFormattedValueProvider
class AnnotationValueProvider: ISCIFormattedValueProvider {
    func formatValue(with axisInfo: SCIAxisInfo?) -> ISCIString? {
        axisInfo != nil ? NSString(string: " \(axisInfo!.axisFormattedDataValue) ") : nil
    }
}

