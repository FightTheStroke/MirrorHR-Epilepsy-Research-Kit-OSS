//
//  CoreDataChart.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 11/04/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import RoberdanToolBox
import SwiftUI
import Charts

// MARK: LEGACY CHART

struct CoreDataStatsChart: View {
    var statsDictionary: [ChartSupportStruct]
    var frameMaxHeight: CGFloat

    private var maxValue: Int
    private var numValues: Int
    private var keys: [String]
    private var values: [Int]

    @State private var lineOffset: CGFloat = 8 // Vertical line offset
    @State private var selectedXPos: CGFloat = 8 // User X touch location
    @State private var selectedYPos: CGFloat = 0 // User Y touch location
    @State private var isSelected: Bool = false // Is the user touching the graph

    init(statsDictionary: [ChartSupportStruct], frameMaxHeight: Int) {
        self.statsDictionary = statsDictionary
        self.frameMaxHeight = CGFloat(frameMaxHeight - 24)
        let cnt = statsDictionary.count
        numValues = cnt > 1 ? cnt - 1 : 1
        keys = statsDictionary.map { statDictionary -> String in
            statDictionary.dictionary.key
        }
        values = statsDictionary.map { statDictionary -> Int in
            statDictionary.dictionary.value
        }
        maxValue = values.max() ?? 1
        if maxValue == 0 {
            maxValue = 1
        }
//        mainDebugger.append("CoreDataStatsChart maxValue = \(maxValue)")
    }

    func drawGrid() -> some View {
        VStack(spacing: 0) {
            Color.primary.frame(height: 1, alignment: .center)
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 8, height: frameMaxHeight)
                ForEach(0 ..< numValues, id: \.self) { _ in
                    Color.primary.frame(width: 1, height: frameMaxHeight, alignment: .center)
                    Spacer()
                }
                Color.primary.frame(width: 1, height: frameMaxHeight, alignment: .center)
                Color.clear
                    .frame(width: 8, height: frameMaxHeight)
            }
            Color.primary.frame(height: 1, alignment: .center)
        }
    }

    func drawActivityGradient() -> some View {
        LinearGradient(gradient: Gradient(colors: [Color(red: 251 / 255, green: 82 / 255, blue: 0), .white]), startPoint: .top, endPoint: .bottom)
            .padding(.horizontal, 8)
            .padding(.bottom, 1)
            .opacity(0.8)
            .mask(
                GeometryReader { geo in
                    Path { myPath in
                        // Used for scaling graph data
                        let safeMaxValue = maxValue == 0 ? 1 : maxValue
                        let scale: CGFloat = geo.size.height / CGFloat(safeMaxValue)
                        var index: CGFloat = 0

                        // Move to the starting y-point on graph
                        myPath.move(to: CGPoint(x: 8, y: geo.size.height - (CGFloat(values[Int(index)]) * scale)))

                        // For each week draw line from previous week
                        for _ in values {
                            if index != 0 {
                                myPath.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / CGFloat(numValues)) * index, y: geo.size.height - (CGFloat(values[Int(index)]) * scale)))
                            }
                            index += 1
                        }

                        // Finally close the subpath off by looping around to the beginning point.
                        myPath.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / CGFloat(numValues)) * (index - 1), y: geo.size.height))
                        myPath.addLine(to: CGPoint(x: 8, y: geo.size.height))
                        myPath.closeSubpath()
                    }
                }
            )
    }

    func drawActivityLine() -> some View {
        GeometryReader { geo in
            Path { myPath in
                let safeMaxValue = maxValue == 0 ? 1 : maxValue
                let scale: CGFloat = geo.size.height / CGFloat(safeMaxValue)
                var index: CGFloat = 0
                myPath.move(to: CGPoint(x: 8, y: geo.size.height - (CGFloat(values[0]) * scale)))
                for _ in values {
                    if index != 0 {
                        myPath.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / CGFloat(numValues)) * index, y: geo.size.height - (CGFloat(values[Int(index)]) * scale)))
                    }
                    index += 1
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 80, dash: [], dashPhase: 0))
            .foregroundColor(Color(red: 251 / 255, green: 82 / 255, blue: 0))
        }
    }

    func drawLogPoints() -> some View {
        GeometryReader { geo in
            let safeMaxValue = maxValue == 0 ? 1 : maxValue
            let scale: CGFloat = geo.size.height / CGFloat(safeMaxValue)
            let fgColor = Color(red: 251 / 255, green: 82 / 255, blue: 0)
            ForEach(0 ..< values.count, id: \.self) { index in
                let offsetCalcX: CGFloat = 8 + ((geo.size.width - 16) / CGFloat(numValues)) * CGFloat(index) - 5
                let offsetCalcY: CGFloat = (geo.size.height - (CGFloat(values[index]) * scale)) - 5
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: 80, dash: [], dashPhase: 0))
                    .frame(width: 10, height: 10, alignment: .center)
                    .foregroundColor(fgColor)
                    .background(Color.white)
                    .cornerRadius(5)
                    .offset(x: offsetCalcX, y: offsetCalcY)

                VStack(alignment: .center, spacing: 0) {
                    Text(keys[index]).font(.caption)
                }.offset(x: offsetCalcX, y: frameMaxHeight + 8)

                VStack(alignment: .center, spacing: 0) {
                    Text("\(values[index])").font(.caption)
                }.offset(x: offsetCalcX, y: -16)
            }
        }
    }

    var body: some View {
        drawGrid()
            .opacity(0.2)
            .overlay(drawActivityGradient())
            .overlay(drawActivityLine())
            .overlay(drawLogPoints())
    }
}


// MARK: NEW CHART
@available(iOS 16.0, *)
struct CoreDataStatsChartV2: View {
    var statsDictionary: [ChartSupportStruct]
    var frameMaxHeight: CGFloat
    
    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(1.0), Color.accentColor.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

    init(statsDictionary: [ChartSupportStruct], frameMaxHeight: Int) {
        self.statsDictionary = statsDictionary
        self.frameMaxHeight = CGFloat(frameMaxHeight)
    }

    var body: some View {
        Chart {
            ForEach(statsDictionary, id: \.self) { chartStruct in
                let data = chartStruct.dictionary
                BarMark(x: .value(data.key, String(data.key)),
                        y: .value("", data.value))
                    .accessibilityLabel(data.key)
            }
            .foregroundStyle(linearGradient)
            .alignsMarkStylesWithPlotArea()
            .cornerRadius(5)
        }
        .frame(height: frameMaxHeight)
    }
}
