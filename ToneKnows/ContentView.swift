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
    @State var showingDetail = false
    @ObservedObject var model = ContentViewModel()
//    let toneFramework = ToneFramework.shared
    init() {
     //   toneFramework.start()
    }

    
    var body: some View {
  
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Try it")
                }
            
            AboutUsView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("About us")
                }
            
            TryItView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Try it")
                }
            
            ContacUsView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Contact us")
                }
                
            }.sheet(isPresented: $showingDetail){
                SheetDetailView(showingDetail: $showingDetail, url: model.newNotification ?? "")
//            }.onReceive(NotificationCenter.default.publisher(for: model.notificationName), perform: { _ in
//                showingDetail.toggle()
            }
//            }).onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("get_clients")), perform: { _ in
//                print(UserDefaults.standard.string(forKey: "clientID") ?? "0" )
//            toneFramework.setClientId(clientID: UserDefaults.standard.string(forKey: "clientID") ?? "0")
//            })
        
    }
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
            ImageViewController(imageUrl: url)
            .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
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
