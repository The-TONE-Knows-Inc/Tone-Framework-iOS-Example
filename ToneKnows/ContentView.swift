//
//  ContentView.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 1/02/22.
//

import SwiftUI
import Combine
import Foundation
import ToneListen

struct ContentView: View {
    init() {
        UITabBar.appearance().isHidden = true
        let toneFramework = ToneFramework()
        toneFramework.start()
    }
    @StateObject var menuData = MenuViewModel()
    @State var showingDetail = false
    @ObservedObject var model = ContentViewModel()
    @Namespace var animation
    
    var body: some View {
        HStack(spacing:0){
            Drower(animation: animation)
            TabView(selection: $menuData.selectedMenu){
                
                GeometryReader{ geo in
                    ZStack {
                        if model.thereClients ?? false {
                            AsyncImages(
                                url: URL(string: menuData.clients.filter({ client in
                                    return client.name == menuData.selectedMenu
                                }).first?.image ?? "")!,
                                        placeholder: Text("")
                            ).aspectRatio(contentMode: .fit)
                        }
                    }.sheet(isPresented: $showingDetail){
                        SheetDetailView(showingDetail: $showingDetail, url: model.newNotification ?? "")
                    }
                    
                    .onReceive(NotificationCenter.default.publisher(for: model.notificationName), perform: { _ in
                        print("Received notification: \(model.newNotification ?? "")")
                        showingDetail.toggle()
                    })
                    
                     
                }
               
                Text(menuData.selectedMenu)
                
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .onAppear(perform: {
            menuData.loadImageFromStorage()
        })
        .frame(width: UIScreen.main.bounds.width)
        .offset(x: menuData.showDrawer ? 125: -125)
        .overlay(
            ZStack {
                if !menuData.showDrawer {
                    DrowerCloseButton(animation: animation)
                        .padding()
                }
            },
            alignment: .topLeading
        )
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
                        //.edgesIgnoringSafeArea(.all)
                        

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
