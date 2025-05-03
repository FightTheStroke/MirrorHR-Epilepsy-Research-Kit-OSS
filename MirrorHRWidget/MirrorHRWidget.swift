//
//  MirrorHRWidget.swift
//  MirrorHRWidget
//
//  Created by Roberto D’Angelo on 27/05/23.
//  Copyright © 2023 FightTheStroke Foundation. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import MirrorHRKit

let fastLogUrlString = "MirrorHR://fastLog"
let sharedDefaults = UserDefaults(suiteName: "group.mirror-labs.Epilepsy-Research-Kit")
let shortAppName = "MirrorHR"

final class WidgetSupportClass: ObservableObject {
    static var shared: WidgetSupportClass = WidgetSupportClass()
    
    private init() {
        loadTopLoggedSymptoms()
    }
    
    @Published var topLoggedSymptoms: [HandledSymptomsEvents] = []
    
    public func refresh() -> [HandledSymptomsEvents] {
        loadTopLoggedSymptoms()
        return topLoggedSymptoms
    }
    
    internal func loadTopLoggedSymptoms() {
        if let data = sharedDefaults?.data(forKey: "topLoggedSympts") {
            let decoder = JSONDecoder()
            if let loadedSympts = try? decoder.decode([HandledSymptomsEvents].self, from: data) {
                topLoggedSymptoms = loadedSympts
            } else {
                topLoggedSymptoms = []
            }
        }
    }
    
}

// MirrorHR://callHelp
struct Provider: IntentTimelineProvider {
    let widgedSupport: WidgetSupportClass = .shared
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), topLoggedSympts: [])
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), topLoggedSympts: widgedSupport.refresh())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Fetch updated topLoggedSympts from shared UserDefaults
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, topLoggedSympts: widgedSupport.refresh())
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let topLoggedSympts: [HandledSymptomsEvents]
}

struct MirrorHRWidgetEntryView : View {
    @Environment(\.widgetFamily) var size
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    let url = URL(string: "MirrorHR://callHelp")!
    
    var body: some View {
        let bgkColor: Color = colorScheme == .dark ? .black : .white
        switch size {
        case .systemSmall:
            Button(action: {
                print("Help me tapped")
            }) {
                VStack {
                    Image("MirrorShield")
                        .resizable()
                        .scaledToFit()
                    Text("MirrorHR: Help me!")
                        .fontWeight(.bold)
                        .font(.title2)
                }
            }
            .widgetURL(url)
            .widgetBackground(bgkColor)
        case .systemMedium, .systemLarge, .systemExtraLarge:
            FastLogHomeWidgetView()
                .widgetBackground(bgkColor)
        default:
            Button(action: {
                print("Help me tapped")
            }) {
                HStack {
                    Text("MirrorHR: Help me!")
                        .fontWeight(.bold)
                        .font(.title)
                }
            }
            .widgetURL(url)
            .widgetBackground(bgkColor)
        }
    }
}

struct MirrorHRWidget: Widget {
    let kind: String = "MirrorHRWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MirrorHRWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MirrorHR")
        .description("This is MirrorHR Widget for fast log of some symptoms or asking for help")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

