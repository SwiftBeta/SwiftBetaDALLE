//
//  ContentView.swift
//  SwiftBetaDALLE
//
//  Created by Home on 10/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GenerateView()
                .tabItem {
                    Image(systemName: "wand.and.stars.inverse")
                    Text("Generate")
                }
            EditView()
                .tabItem {
                    Image(systemName: "scribble.variable")
                    Text("Edit")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
