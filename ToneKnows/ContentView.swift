//
//  ContentView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @State private var isFirstLaunch: Bool
    @State private var showingSplash = true
    @ObservedObject var model = ContentViewModel()
    init() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedOnce") {
            _isFirstLaunch = State(initialValue: false)
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            _isFirstLaunch = State(initialValue: true)
        }
    }

    
    var body: some View {
        if showingSplash {
            SplashScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showingSplash = false
                    }
                }
        }else{
            NavigationView {
                TryItView()
            }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("HeaderLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 15)
            Text("Know your frequencies")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.all)
            Spacer()
            Button("Privacy Policy") {
                openTermsAndConditions()
            }
            .font(.footnote)
            .foregroundColor(.white)
            .padding()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    func openTermsAndConditions() {
        if let url = URL(string: "https://thetoneknows.com/privacy") {
            UIApplication.shared.open(url)
        }
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

struct SheetDetailDataView: View {
    @ObservedObject var model = ContentViewModel()
    @Binding var showingDetail: Bool
    @Binding var imageData: Data
    
    var body: some View {
        VStack(spacing: 15) {
            Text("TAG Content")
            Button(action: {
                showingDetail.toggle()
            }) {
                Text("Back")
            }
            ImageDataViewController(imageData: $imageData)
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ImageDataViewController: View {
    @Binding var imageData: Data
    
    var body: some View {
        if let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .clipped()
        } else {
            Text("No image available")
                .foregroundColor(.gray)
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
        guard let url = URL(string: imageURL) else {
            return
        }
        let cache = URLCache.shared
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)

        if let data = cache.cachedResponse(for: request)?.data {
            self.data = data
        } else {
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self, let data = data, let response = response else { return }

                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)

                DispatchQueue.main.async {
                    self.data = data
                }
            }.resume()
        }
    }
}
