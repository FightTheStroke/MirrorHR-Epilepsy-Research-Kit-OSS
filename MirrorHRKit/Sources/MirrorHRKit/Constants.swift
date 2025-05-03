//
//  Constants.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 03/10/2020.
//

import Foundation
import RoberdanToolBox
import SwiftUI
import SharedPkg

// MARK: email Contacts
public let supportEmail = "helpme@mirrorhr.org"
public let suggestionsEmail = "helpme@mirrorhr.org"
public let privateEmail = "helpme@mirrorhr.org"

// MARK: - Colors
public let mainColor: Color = Color("kMainBg")
public let darkShadow: Color = Color("kDarkShadow")
public let lightShadow: Color = Color("kLightShadow")

//let stefiViolet: Color = Color(uiColor: UIColor(hexString: "7675E1"))
public let stefiViolet: Color = .purple
public let stefiAzure: Color = Color(uiColor: UIColor(hexString: "30B0C7"))
public let stefiError: Color = Color(uiColor: UIColor(hexString: "30B0C7"))
public let stefiRed: Color = .red
public let stefiGreen: Color = .green
public let stefiPurple: Color = .purple
public let stefiBlue: Color = .blue

public let tertiaryBgkColor: UIColor = .tertiarySystemBackground
public let secondaryBgkColor: UIColor = .secondarySystemBackground

public let sampleChartActionDebug1 = {
    MirrorHRMainClass.shared.realTimeChart.testSciChart(bpmDataSeries: MirrorHRMainClass.shared.bpmDataSeries)
}

// Images
internal let noApp = Image(systemName: "applewatch")
internal let appleWatchWavesImage = Image(systemName: "applewatch.radiowaves.left.and.right")
internal let streamingImage = Image(systemName: "iphone.radiowaves.left.and.right")
internal let internetStreamingImage = Image(systemName: "iphone.radiowaves.left.and.right")
internal let internetStreamingImageString = "person.icloud"
internal let removeItemImage = Image(systemName: "minus.circle.fill")
internal let checkMarkFilledImageString = "checkmark.circle.fill"
internal let checkMarkEmptyImageString = "circle"
internal let cloudUpImage = Image(systemName: "icloud.and.arrow.up")
internal let cloudDownImage = Image(systemName: "icloud.and.arrow.down")
internal let patientImage = Image(systemName: "person.circle")
internal let caregiverImage = Image(systemName: "figure.run.circle")

let lowBatteryImg = "battery.25"
let fullBatteryImg = "battery.100"

// MARK: NLP
// let isMedicationManagerInBeta: Bool = true
// TODO: remember to re-enable NLP when ready
let defaultPreferredLanguage: String = "NLPisDisabled"
// let defaultPreferredLanguage: String = "en"

let isVideoDiaryAvailableInThisLanguage: Bool = Locale.preferredLanguages.first == defaultPreferredLanguage

// MARK: TabViewController
public class TabViewController: ObservableObject {
    public static let shared = TabViewController()
    @Published public var tabView: Int = Tab.home.rawValue
    private init() {
            // singleton
    }
}

// MARK: ComingSoonView
public struct ComingSoonView: View {
    @EnvironmentObject var showSheet: SheetViewController
    var text: String
    public var body: some View {
        VStack {
            Image(systemName: "bookmark")
            Text(comingSoonMsg + "\n\(text)")
                .multilineTextAlignment(.center)
        }.font(.title2)
    }
}
