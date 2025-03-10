//
//  FarmVisionApp.swift
//  FarmVision
//
//  Created by Mekhak Ghapantsyan on 2/25/25.
//

import SwiftUI

@main
struct FarmVisionApp: App {
  
  @State private var appModel = AppModel()
  @State var purcheseName: String = ""
  @State var coins: Int = 1000
  
  init() {
    GestureComponent.registerComponent()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(appModel)
    }
    
    WindowGroup(id: "Shop") {
      ShopView(coins: $coins, purcheseName: $purcheseName)
        .environment(appModel)
    }
    
    ImmersiveSpace(id: appModel.immersiveSpaceID) {
      FarmRealityView(purchaseName: $purcheseName, coins: $coins)
        .environment(appModel)
        .onAppear {
          appModel.immersiveSpaceState = .open
        }
        .onDisappear {
          appModel.immersiveSpaceState = .closed
        }
      
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)
  }
}
