//
//  TestStreamListView.swift
//
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import SwiftUI

public struct TestStreamListView: View {
  @EnvironmentObject var bonjourConnectionManager: LocalStreamingManager

  public var body: some View {
    ScrollView {
//      ScrollViewReader { reader in
//        VStack(alignment: .leading, spacing: 20) {
//          ForEach(bonjourConnectionManager.messages) { message in
//            StreamMessageBodyView(message: message)
//              .onAppear {
//                if message == bonjourConnectionManager.messages.last {
//                  reader.scrollTo(message.id)
//                }
//              }
//          }
//        }
//        .padding(16)
//      }
    }
    .background(Color(UIColor.systemBackground))
  }
}
