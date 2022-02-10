//
//  ContentView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI
import Combine
import Foundation
//import ToneListen

struct ContentView: View {
    init() {
        //UITabBar.appearance().isHidden = true
        
    }
    @StateObject var menuData = MenuViewModel()

    @Namespace var animation
    
    var body: some View {
            TabView {
                DemoView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Demo")
                    }
                ClientsView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Clients")
                    }
                }
            .tabViewStyle(PageTabViewStyle())
            
            
       // .frame(width: UIScreen.main.bounds.width)
        .environmentObject(menuData)
        
        
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private var cancellable: AnyCancellable?
    init(url: URL) {
        //self.url = url
        self.url = url
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .map { UIImage(data: $0.data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.image, on: self)
    }

    func cancel() {}
}

struct SheetDetailView: View {
    @ObservedObject var model = ContentViewModel()
    @Binding var showingDetail: Bool
    @State  public var url : String
           
    var body: some View {
        VStack(spacing: 15) {
            Text("TAG Content")
            Button(action: {
                showingDetail.toggle()
            }) {
                Text("Back")
            }
            AsyncImages(
                        url: URL(string: url)!,
                        placeholder: Text("")
            ).aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
    }
}

struct AsyncImages<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader
    private let placeholder: Placeholder?
    
    init(url: URL, placeholder: Placeholder? = nil) {
        loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }

    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
            Group {
                if loader.image != nil {
                    
                    Image(uiImage: loader.image!)
                        .resizable()
                        .scaledToFit()
                        //.frame(width: 50, height: 50, alignment: .trailing)
                        .edgesIgnoringSafeArea(.all)
                        

                } else {
                    placeholder
                }
            }
        }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
    }
}



struct ImageViewController: View {
    @ObservedObject var url: LoadUrlImage

    init(imageUrl: String) {
        url = LoadUrlImage(imageURL: imageUrl)
    }

    var body: some View {
          Image(uiImage: UIImage(data: self.url.data) ?? UIImage())
              .resizable()
              .clipped()
    }
}

class LoadUrlImage: ObservableObject {
    @Published var data = Data()
    init(imageURL: String) {
        let cache = URLCache.shared
        let request = URLRequest(url: URL(string: imageURL)!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
        if let data = cache.cachedResponse(for: request)?.data {
            self.data = data
        } else {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response {
                let cachedData = CachedURLResponse(response: response, data: data)
                                    cache.storeCachedResponse(cachedData, for: request)
                    DispatchQueue.main.async {
                        self.data = data
                    }
                }
            }).resume()
        }
    }
}
