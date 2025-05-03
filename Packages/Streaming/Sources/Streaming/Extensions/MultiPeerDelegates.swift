//
//  MultiPeerDelegates.swift
//  
//
//  Created by Roberto D’Angelo on 04/09/22.
//

import Foundation
import MultipeerConnectivity
import SharedPkg

extension LocalStreamingManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    // send function: it sends a StreamingMessage, but it should be used only by functions like sendBpm or sendCommand
    internal func send(_ streamMessage: StreamingMessage) {
        //        messages.append(streamMessage)
        guard
            let session = session,
            let data = streamMessage.jsonString()?.data(using: .utf8),
            !session.connectedPeers.isEmpty
        else {
            mainDebugger.append("Can't send the streaming message. Maybe there are no peers connected", .justALog, sourceModule: "Streaming Manager - send stream message")
            return
        }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            mainDebugger.append("Error: \(error.localizedDescription)", .error, sourceModule: "StreamingManager send function")
        }
    }
}

extension LocalStreamingManager: MCSessionDelegate {
    // MARK: here is where it receives messages from the server
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard isEnabled else {
            return
        }
        guard let jsonString = String(data: data, encoding: .utf8),
              let message = StreamingMessage.loadFromJson(jsonString: jsonString) else {
            return
        }
        
        dispatchStreamingMessage(message)
        mainDebugger.append("StreamingManager received: \(String(describing: message.jsonString()))")
    }
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !peers.contains(peerID) {
                DispatchQueue.main.async {
                    self.connectedToStream = true
                    self.peers.insert(peerID, at: 0)
                }
            }
            sendKeyFlowThresholds()
        case .notConnected:
            DispatchQueue.main.async {
                if let index = self.peers.firstIndex(of: peerID) {
                    self.peers.remove(at: index)
                }
                if self.peers.isEmpty && !self.isServer {
                    self.connectedToStream = false
                }
            }
        case .connecting:
            mainDebugger.append("Connecting to: \(peerID.displayName)")
        @unknown default:
            mainDebugger.append("Unknown state: \(state)", .error, sourceModule: "StreamingManager - session func didchangestate")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        mainDebugger.append("received stream InputStream")
        
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        mainDebugger.append("Receiving streaming history", .error, sourceModule: "StreamingManager - session func receivingResource")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard
            let localURL = localURL,
            let data = try? Data(contentsOf: localURL)
        else {
            return
        }
        // Do something with data
        mainDebugger.append("received data as: \(String(describing: data))", .error, sourceModule: "StreamingManager - session received data when it should have not")
    }
}

extension LocalStreamingManager: MCBrowserViewControllerDelegate {
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            mainDebugger.append("browserVieControllerDidFinish")
        }
    }
    
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session?.disconnect()
        browserViewController.dismiss(animated: true)
        dispatchMainEvent(.cancelledJoinStream, "StreamingManager")
    }
}
