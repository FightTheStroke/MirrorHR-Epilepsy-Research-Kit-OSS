//
//  BlockingProgressView.swift
//  
//
//  Created by Roberto D’Angelo on 30/07/22.
//

import Foundation
import SwiftUI

// MARK: - BlockingActionInProgressModel
/// It handles when complex operations are happening and prevent user from interacting with potentially dangerous views.
/// Example: when it's restoring data from backup it prevents from interacting with the diary view so it can't mess with the coredata db and lead to an inconsitent state
public final class BlockingActionInProgressModel: ObservableObject {
    public static let shared: BlockingActionInProgressModel = BlockingActionInProgressModel()
    @Published public var blockingActionIsInProgress: Bool = false
    private init() {
        // singleton
    }
}

public struct HandleBlockingActionsModifier: ViewModifier {
    @ObservedObject var blockingActionInProgressModel: BlockingActionInProgressModel = .shared
    var hasToBeDisabled: Bool
    
    public init (hasToBeDisabled: Bool = false) {
        self.hasToBeDisabled = hasToBeDisabled
    }
    
    public func body(content: Content) -> some View {
        content
        // to avoid that user mess coredata when it's importing or exporting data
            
            .if(blockingActionInProgressModel.blockingActionIsInProgress) {
                $0
                    .overlay(FullScreenProgressView())
                    .disabled(hasToBeDisabled)
            }
    }
}

public struct FullScreenProgressView: View {
    public var fillColor: Color = .primary
    public var textColor: Color = .red
    public var message: String = "AttentionRiskyWorkInProgressMessage".local()
    public var opacity: Double = 0.85
    
    public var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 15)
                .fill(fillColor)
                .opacity(opacity)
            VStack {
                ActivityIndicator()
                    .frame(width: 200, height: 200)
                    .foregroundColor(textColor)
                Text(message)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .foregroundColor(textColor)
        }
    }
}

public struct ActivityIndicator: View {
    @State private var isAnimating: Bool = false
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(0..<5) { index in
                Group {
                    Circle()
                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                        .scaleEffect(calcScale(index: index))
                        .offset(y: calcYOffset(geometry))
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                .animation(Animation
                    .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                    .repeatForever(autoreverses: false), value: isAnimating
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }
    
    private func calcScale(index: Int) -> CGFloat {
        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }
    
    private func calcYOffset(_ geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width / 10 - geometry.size.height / 2
    }
    
}
