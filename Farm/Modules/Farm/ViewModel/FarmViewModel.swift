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
    let rangesForX: [ClosedRange<Float>]  = [(-2.0...(-0.5)), (0.5...2.0)]
    let rangesForZ: [ClosedRange<Float>] =  [(-2.0...(-0.5)), (0.5...2.0)]
    for _ in 0..<10 {
      let selectedRangeforX = rangesForX.randomElement()!
      let selectedRangeforZ = rangesForZ.randomElement()!
      let x = Float.random(in: selectedRangeforX)
      let y: Float = 0.0
      let z = Float.random(in: selectedRangeforZ)
      guard let clone = grassModel?.clone(recursive: true) else { return }
      
      let bounds = grassModel?.visualBounds(relativeTo: nil)
      let originalSize = bounds?.extents
      let scaledSize = SIMD3(
        (originalSize?.x ?? 0.0) * 1000,
        (originalSize?.y ?? 0.0) * 1000,
        (originalSize?.z ?? 0.0) * 1000
      )
      let shape = ShapeResource.generateBox(size: scaledSize)
      clone.components.set(CollisionComponent(shapes: [shape]))
      clone.components.set(PhysicsBodyComponent(
        massProperties: .default,
        material: .default,
        mode: .static
      ))
      clone.generateCollisionShapes(recursive: true)
      clone.name = "Grass"
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
      sickleModel?.name = "Sickle"
    } catch {
      print("Error Loading Sickle Usdz File: \(error)")
    }
  }
  
  func loadAxeModel() {
    do {
      let axe = try ModelEntity.loadModel(named: "axe")
      axe.position = [0,-0.2,-0.3]
      sickleModel?.removeFromParent()
      sickleModel = nil
      sickleModel = axe
      
    } catch {
      print("Error Loadig Axe Usdz File: \(error)")
    }
  }
  
}
