//
//  FarmViewModel.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/10/25.
//

import Foundation
import RealityKit
import _RealityKit_SwiftUI

final class FarmViewModel: ObservableObject {
  
  @Published var grassModel: ModelEntity?
  @Published var sickleModel: ModelEntity?
  
  func loadGrasModel() {
    do {
      grassModel = try ModelEntity.loadModel(named: "bush")
      grassModel?.scale = [0.001,0.001,0.001]
      grassModel?.position = [0,0,-0.5]
    } catch {
      print("Error Loading  Grass Usdz File: \(error)")
    }
  }
  
  func generateGrassesOn(content: RealityViewCameraContent) {
    let rangesForX  = [(-3...(-1)), (1...3)]
    let rangesForZ =  [(-3...(-1)), (1...3)]
    for _ in 0..<10 {
      let selectedRangeforX = rangesForX.randomElement()!
      let selectedRangeforZ = rangesForZ.randomElement()!
      let x = Float(Int.random(in: selectedRangeforX))
      let y: Float = 0.0
      let z = Float(Int.random(in: selectedRangeforZ))
      guard let clone = grassModel?.clone(recursive: true) else { return }
      clone.position = [x,y,z]
      content.add(clone)
    }
  }
  
  func loadSickleModel() {
    do {
      sickleModel = try ModelEntity.loadModel(named: "Sickle")
      sickleModel?.scale = [0.0001,0.0001,0.0001]
      let rotationY = simd_quatf(angle: -.pi/4, axis: [0, 1, 0])
      let rotationX = simd_quatf(angle: .pi/4, axis: [1, 0, 0])
      sickleModel?.transform.rotation = rotationX * rotationY
      sickleModel?.position = [0,-0.2,-0.3]
    } catch {
      print("Error Loading Sickle Usdz File: \(error)")
    }
  }
  
}
