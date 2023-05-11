//
//  HomeView.swift
//  PhotoRush
//
//  Created by Rexan Wong on 18/4/2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Which game would you like to play now?")
                    .font(.headline)
                    .padding()
                
                NavigationLink(destination: ContentView(), label: {
                    Text("PhotoAlbum Game")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                
                NavigationLink(destination: CameraView(), label: {
                    Text("AR Game")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
            }
        }
            
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
