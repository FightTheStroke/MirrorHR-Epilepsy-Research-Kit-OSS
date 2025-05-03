//
//  StreamMessageBodyView.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 13/08/2022.
//

import SwiftUI
import SharedPkg

public struct StreamMessageBodyView: View {
    let message: StreamingMessage
    
    public var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text("type: \(message.messageType.rawValue)\n body: \(message.body ?? "")\n value: \(message.valueInt ?? 0)\n jsonEvent: \(message.eventJson ?? "")")
                    .font(.body)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(message.isUser ? .green : Color("rw-dark"))
                    .cornerRadius(9)
                TimestampView(message: message)
            }
        }
    }
}
