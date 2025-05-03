//
//  File.swift
//  
//
//  Created by Roberto D’Angelo on 24/02/24.
//

import Foundation
import SwiftUI

public struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color = .green
    var size: CGFloat = 1
    
    public init(color: Color, size: CGFloat) {
        self.color = color
        self.size = size 
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
                .font(.body)
        } icon: {
            configuration.icon
                .imageScale(.medium)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 7 * size).frame(width: 28 * size, height: 28 * size).foregroundColor(color))
        }
    }
}
