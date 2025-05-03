//
//  TimestampView.swift
//
//
//  Created by Roberto D’Angelo on 12/08/22.
//

import SwiftUI
import SharedPkg

public struct TimestampView: View {
  let message: StreamingMessage

  public var body: some View {
    HStack(spacing: 2) {
        Text(message.displayName)
      Text("@")
      Text("\(message.time, formatter: DateFormatter.timestampFormatter)")
      if !message.isUser {
        Spacer()
      }
    }
    .font(.caption)
    .foregroundColor(Color("rw-dark"))
  }
}
