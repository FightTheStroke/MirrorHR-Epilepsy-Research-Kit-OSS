//
//  TestMirrorHRStream.swift
//
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import SwiftUI

public struct TestMirrorHRStream: View {
    @EnvironmentObject var bonjourConnectionManager: LocalStreamingManager
    @State var timer: Timer?
    
    public func run() {
        var cnt = 0
        bonjourConnectionManager.sendStartStreaming()
        bonjourConnectionManager.sendBPM(124)
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            cnt += 1
            bonjourConnectionManager.sendBPM(Int.random(in: 60...120))
        }
    }
    
    public func stop() {
        timer?.invalidate()
        bonjourConnectionManager.sendStopStreaming()
    }
    
    public var body: some View {
        HStack {
            Button("Start sending stream") {
                run()
            }
            Spacer()
            Button("Stop") {
                stop()
            }
            Button("Leave") {
                bonjourConnectionManager.leaveStream()
            }
        }
        .font(.title)
        .padding()
    }
}

public struct TestStreamView: View {
    @EnvironmentObject var bonjourConnectionManager: LocalStreamingManager
    @State private var messageText = ""
    
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            streamInfoView
            TestStreamListView()
                .environmentObject(bonjourConnectionManager)
            if bonjourConnectionManager.isServer {
                TestMirrorHRStream()
                    .environmentObject(bonjourConnectionManager)
                messageField
            } else {
                Button("Leave") {
                    bonjourConnectionManager.leaveStream()
                }
            }
        }
        .navigationBarTitle("Stream", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Leave") {
                    bonjourConnectionManager.leaveStream()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var messageField: some View {
        VStack(spacing: 0) {
            Divider()
            // swiftlint:disable:next trailing_closure
            TextField("Enter Message", text: $messageText, onCommit: {
                guard !messageText.isEmpty else { return }
                bonjourConnectionManager.sendMessage(messageText)
                messageText = ""
            })
            .padding()
        }
    }
    
    private var streamInfoView: some View {
        VStack(alignment: .leading) {
            Divider()
            HStack {
                Text("Devices in stream:")
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.headline)
                if bonjourConnectionManager.peers.isEmpty {
                    Text("Empty")
                        .font(Font.caption.italic())
                        .foregroundColor(Color("rw-dark"))
                } else {
                    streamParticipantsView
                }
            }
            .padding(.top, 8)
            .padding(.leading, 16)
            Divider()
        }
        .frame(height: 44)
    }
    
    private var streamParticipantsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(bonjourConnectionManager.peers, id: \.self) { peer in
                    Text(peer.displayName)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 6)
                        .background(Color("rw-dark"))
                        .foregroundColor(.white)
                        .font(.body.bold())
                        .cornerRadius(9)
                }
            }
        }
    }
}
