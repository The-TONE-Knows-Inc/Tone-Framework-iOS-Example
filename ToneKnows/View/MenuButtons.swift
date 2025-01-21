//
//  MenuButtons.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 2/02/22.
//

import SwiftUI

struct MenuButtons: View {
    var clientID: String
    var name: String
    var image: String
    @Binding var selectedMenu: String
    
    var body: some View {
        Button(action: {
            if !clientID.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name("get_clients"), object: true)
                withAnimation(.spring()) {
                    selectedMenu = name
                    UserDefaults.standard.set(clientID, forKey: "clientID")
                }
            }
        }, label: {
            HStack(spacing: 15){
                HStack {
                    ImageViewController(imageUrl: image).aspectRatio(contentMode: .fit)
                }.frame(width: 50, height: 50, alignment: .leading)
                Text(name)
                    .foregroundColor(selectedMenu == name ? .black : .white)
            }
            .padding(.horizontal)
            .padding(.vertical,12)
            .frame(width: 300, alignment: .leading)
            .background(
                ZStack{
                    if selectedMenu == name {
                        Color.white
                            .cornerRadius(10)
                         //   .matchedGeometryEffect(id: "TAB", in: animation)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(10)
        })
    }
}

struct MenuButtons_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
