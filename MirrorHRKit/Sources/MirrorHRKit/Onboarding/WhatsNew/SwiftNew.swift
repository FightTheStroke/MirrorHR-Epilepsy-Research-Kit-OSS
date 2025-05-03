//
//  Created by Ming on 11/6/2022.
//  source: https://levelup.gitconnected.com/introducing-swiftnewkit-show-whats-new-effortless-53850fefa8a5

import SwiftUI
import SharedPkg
import OSLog
 
@available(iOS 14, watchOS 7.0, *)
public struct WhatsNewView: View {
    @State var items: [Vmodel] = []
    @State var loading = true
    
    @State var align: HorizontalAlignment = .center
    @State var color: Color = .accentColor
    @State var labelColor: Color = Color(UIColor.systemBackground)
    let logger = Logger(subsystem: "Views", category: "WhatsNewView")
    
    public init() {

    }
 
    public var body: some View {
        VStack(alignment: align) {
            Spacer()
            Text("WhatsNewInThisVersion".local()).bold().font(.largeTitle).multilineTextAlignment(.center)
            Text("\(appVersion)")
                .bold().font(.title3).foregroundColor(.secondary)
            Spacer()
            if loading {
                ProgressView()
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(items, id: \.self) { item in
                        ForEach(item.new, id: \.self) { new in
                            HStack(alignment: .top) {
                                ZStack {
                                    color
                                    Image(systemName: new.icon)
                                        .foregroundColor(.white)
                                        .scaledToFill()
                                }
                                .frame(width: 50, height:50)
                                .cornerRadius(15)
                                .padding(.trailing)
                                VStack(alignment: .leading) {
                                    Text(new.title.local()).font(.title2).lineLimit(2)
                                    Text(new.subtitle.local()).font(.headline).foregroundColor(.secondary).lineLimit(2)
                                    Text(new.body.local()).font(.body).foregroundColor(.secondary).lineLimit(4)
                                }
                                Spacer()
                            }.padding(.bottom)
                        }
                    }
                }.frame(width: 300, height: 450)
            }
            Spacer()
            Button {
                OnboardingStateMachine.shared.setOnboarding(to: true)
            } label: {
                Label("restartOnboardingMsg".local(), systemImage: "gearshape.2")
            }
            
            Button {
                OnboardingStateMachine.shared.setOnboarding(to: false)
            } label: {
                HStack {
                    Text("continueMsg".local()).bold()
                    Image(systemName: "arrow.right.circle.fill")
                }
                .frame(width: 300, height: 50)
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(15)
                .padding(.bottom)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    public func loadData() {
        // MARK: Local Data
        if let url = Bundle.module.url(forResource: "whatsNewJsonData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                items = try decoder.decode([Vmodel].self, from: data)
                loading = false
            } catch {
                logger.error("\(error)")
            }
        }
    }
}

// MARK: - Model
public struct Vmodel: Codable, Hashable {
    var version: String
    var new: [Model]
}
public struct Model: Codable, Hashable {
    var icon: String
    var title: String
    var subtitle: String
    var body: String
}

struct SwiftNEW_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView()
    }
}
