//
//  Styles.swift
//  MirrorHR
//
//  Created by Roberto D’Angelo on 25/09/2020.
//

import Foundation
import SwiftUI

#if os(iOS)
    @available(iOS 13.0, watchOS 6.0, *)
    public struct CircleToggleStyle: ToggleStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            ZStack {
                configuration.label.hidden()
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                    .imageScale(.large)
                    .font(.title)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public struct HorizontalCheckmarkToggleStyle: ToggleStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                Rectangle()
                    .foregroundColor(configuration.isOn ? .green : .red)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Circle()
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .overlay(
                                Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .font(.largeTitle)
                                    .frame(width: 8, height: 8, alignment: .center)
                                    .foregroundColor(configuration.isOn ? .green : .gray)
                            )
                            .offset(x: configuration.isOn ? 11 : -11, y: 0)

                    ).cornerRadius(defaultBtnCornerRadius)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public struct PowerToggleStyle: ToggleStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                Rectangle()
                    .foregroundColor(configuration.isOn ? .green : .red)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Circle()
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .overlay(
                                GeometryReader { _ in
                                    Path { path in
                                        if !configuration.isOn {
                                            path.addRoundedRect(
                                                in: CGRect(x: 20, y: 10, width: 10.5, height: 10.5),
                                                cornerSize: CGSize(width: 7.5, height: 7.5),
                                                style: .circular,
                                                transform: .identity
                                            )
                                        } else {
                                            path.move(to: CGPoint(x: 51 / 2, y: 10))
                                            path.addLine(to: CGPoint(x: 51 / 2, y: 31 - 10))
                                        }
                                    }.stroke(configuration.isOn ? Color.green : Color.gray, lineWidth: 2)
                                }
                            )
                            .offset(x: configuration.isOn ? 11 : -11, y: 0)

                    ).cornerRadius(defaultBtnCornerRadius)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)

    public struct VerticalPowerToggleStyle: ToggleStyle {
        public init() {}
        public func makeBody(configuration: Configuration) -> some View {
            VStack {
                configuration.label
                Rectangle()
                    .foregroundColor(configuration.isOn ? .green : .red)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Circle()
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .overlay(
                                GeometryReader { _ in
                                    Path { path in
                                        if !configuration.isOn {
                                            path.addRoundedRect(
                                                in: CGRect(x: 20, y: 10, width: 10.5, height: 10.5),
                                                cornerSize: CGSize(width: 7.5, height: 7.5),
                                                style: .circular,
                                                transform: .identity
                                            )
                                        } else {
                                            path.move(to: CGPoint(x: 51 / 2, y: 10))
                                            path.addLine(to: CGPoint(x: 51 / 2, y: 31 - 10))
                                        }
                                    }.stroke(configuration.isOn ? Color.green : Color.gray, lineWidth: 2)
                                }
                            )
                            .offset(x: configuration.isOn ? 11 : -11, y: 0)

                    ).cornerRadius(defaultBtnCornerRadius)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
    public struct ImageToggleStyle: ToggleStyle {
        var onImageName: String
        var offImageName: String

        public init() {
            onImageName = ""
            offImageName = ""
        }

        public func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                Image(configuration.isOn ? onImageName : offImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 51, height: 31, alignment: .center)
                    .overlay(
                        Circle()
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .offset(x: configuration.isOn ? 11 : -11, y: 0)
                    ).cornerRadius(defaultBtnCornerRadius)
                    .onTapGesture { configuration.isOn.toggle() }
            }
        }
    }

#endif
