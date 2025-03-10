//
//  ContentView.swift
//  FarmVision
//
//  Created by Mekhak Ghapantsyan on 2/25/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
  
  var body: some View {
    ZStack {
      Image(.farmBackground)
        .resizable()
      VStack {
        Text("FarmVision")
          .padding()
          .font(.extraLargeTitle)
          .foregroundStyle(Color.green)
          .glassBackgroundEffect()
        ToggleImmersiveSpaceButton()
      }
    }
    .ignoresSafeArea(.all)
    .padding(0)
  }
  
}

#Preview(windowStyle: .automatic) {
  ContentView()
    .environment(AppModel())
}
