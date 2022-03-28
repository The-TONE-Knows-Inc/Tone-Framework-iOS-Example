//
//  HomeView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 28/02/22.
//

import SwiftUI
import WebKit

struct HomeView: View {
    @StateObject var modelWebView = WebViewModel()
       
   var body: some View {
       WebView(webView: modelWebView.webView)
   }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    let url: URL
    
    init() {
        webView = WKWebView(frame: .zero)
        url = URL(string: "https://thetoneknows.ottchannel.com/")!        
        loadUrl()
    }
    
    func loadUrl() {
        
        webView.load(URLRequest(url: url))
    }
}
