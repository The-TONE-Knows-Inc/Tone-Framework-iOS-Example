//
//  MenuButtons.swift
//  ToneKnows
//
//  Created by Bryan Gómez on 2/02/22.
//

import SwiftUI

struct MenuButtons: View {
    var name: String
    var image: String
    @Binding var selectedMenu: String
    var animation: Namespace.ID
    var body: some View {
        Button(action: {
            withAnimation(.spring()){
                selectedMenu = name
            }
        }, label: {
            HStack(spacing: 15){
                AsyncImages(
                            url: URL(string: image)!,
                            placeholder: Text("")).aspectRatio(contentMode: .fit)
              //  Image(systemName: image)
              //      .font(.title2)
              //      .foregroundColor(selectedMenu == name ? .black : .white)
                Text(name)
                    .foregroundColor(selectedMenu == name ? .black : .white)
            }
            .padding(.horizontal)
            .padding(.vertical,12)
            .frame(width: 200, alignment: .leading)
            .background(
                ZStack{
                    if selectedMenu == name {
                        Color.white
                            .cornerRadius(10)
                            .matchedGeometryEffect(id: "TAB", in: animation)
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
        //Home()
    }
}
