//
//  WebView.swift
//  
//
//  Created by Roberto D’Angelo on 18/09/22.
//

import Foundation
import SwiftUI
import WebKit
import SharedPkg

public struct WebView: View {
    private var url: URL?
    private var urlString: String = "about:blank"
    
    public init(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        self.urlString = urlString
        self.url = url
    }
    
    public var body: some View {
        if self.url == nil {
            Text("Wrong URL")
        } else {
            EmbeddedWebView(urlString)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Link("OpenInBrowserLinkMsg".local(), destination: url!)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

public struct EmbeddedWebView: UIViewRepresentable {
    private var url: URL = URL(string: "about:blank")!
    
    public init(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            mainDebugger.append("EmbeddedWebView", .error, sourceModule: "not valid URL passed" )
            return
        }
        self.url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
