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
  @Published var treeModel: ModelEntity?
  @Published var chickenModel: ModelEntity?
  @Published var farmModel: ModelEntity?
  @Published var marketModel: ModelEntity?
  @Published var cowModel: ModelEntity?
  @Published var eggModel: ModelEntity?
  @Published var milkModel: ModelEntity?
  
  private var chickenPosition: [SIMD3<Float>] = [
    [-600,100,-600],
    [-800,100,-600],
    [-1000,100,-1000],
    [-700,100,-900],
    [-1000,100,-600],
  ]
  private var cowPosition: [SIMD3<Float>] = [
    [600,100,600],
    [800,100,600],
    [1000,100,1000],
    [700,100,900],
    [1000,100,600],
  ]
  
  private var indexForChickenPosition: Int = 0
  private var indexForCowPosition: Int = 0
  
  private func getChickenPosition() -> SIMD3<Float> {
    if indexForChickenPosition == chickenPosition.count {
      indexForChickenPosition = 0
    }
    let pos = chickenPosition[indexForChickenPosition]
    indexForChickenPosition += 1
    return pos
  }
  
  private func getCowPosition() -> SIMD3<Float> {
    if indexForCowPosition == cowPosition.count {
      indexForCowPosition = 0
    }
    let pos = cowPosition[indexForCowPosition]
    indexForCowPosition += 1
    return pos
  }
  
  func loadGrassModel() {
    do {
      grassModel = try ModelEntity.loadModel(named: "bush")
      grassModel?.scale = [0.001,0.001,0.001]
      grassModel?.position = [0,0,-0.5]
    } catch {
      print("Error Loading  Grass Usdz File: \(error)")
    }
  }
  
  func loadFarmModel() {
    do {
      farmModel = try ModelEntity.loadModel(named: "farm")
      farmModel?.scale = [0.001,0.001,0.001]
      farmModel?.position = [0,-1,-3]
      let rotationY = simd_quatf(angle: .pi, axis: [0, 1, 0])
      farmModel?.transform.rotation = rotationY
    } catch {
      print("Error Loading Farm Usdz File: \(error)")
    }
  }
  
  func loadMarketModel() {
    do {
      marketModel = try ModelEntity.loadModel(named: "market")
      marketModel?.scale = [0.006,0.006,0.006]
      marketModel?.position = [5,-1,-1]
    } catch {
      print("Error Loading Farm Usdz File: \(error)")
    }
  }
  
  func loadChicken() {
    do {
      chickenModel = try ModelEntity.loadModel(named: "chicken")
      chickenModel?.scale = [1.2,1.2,1.2]
      let rotationY = simd_quatf(angle: .pi, axis: [0, 1, 0])
      chickenModel?.transform.rotation = rotationY
      guard let farmModel, let chickenModel else { return }
      farmModel.addChild(chickenModel)
      chickenModel.position = getChickenPosition()
      if let animation = chickenModel.availableAnimations.first {
        chickenModel.playAnimation(animation.repeat(), transitionDuration: 0.6)
      }
      loadEggModel()
    } catch {
      print("Error Loading Chicken Usdz File: \(error)")
    }
  }
  
  func loadCowModel() {
    do {
      cowModel = try ModelEntity.loadModel(named: "cow")
      cowModel?.scale = [1,1,1]
      let rotationY = simd_quatf(angle: .pi, axis: [0, 1, 0])
      cowModel?.transform.rotation = rotationY
      guard let farmModel, let cowModel else { return }
      farmModel.addChild(cowModel)
      cowModel.position = getCowPosition()
      if let animation = cowModel.availableAnimations.first {
        cowModel.playAnimation(animation.repeat(), transitionDuration: 0.6)
      }
      loadMilkModel()
    } catch {
      print("Error Loading Cow Usdz File: \(error)")
    }
  }
  
  func loadEggModel() {
    do {
      eggModel = try ModelEntity.loadModel(named: "egg")
      eggModel?.components.set(PhysicsBodyComponent(
        massProperties: .default,
        material: .default,
        mode: .dynamic
      ))
      eggModel?.generateCollisionShapes(recursive: true)
      eggModel?.physicsBody?.isAffectedByGravity = true
    } catch {
      print("Error Loading Egg Usdz File: \(error)")
    }
  }
  
  func loadMilkModel() {
    do {
      milkModel = try ModelEntity.loadModel(named: "milk")
      milkModel?.components.set(PhysicsBodyComponent(
        massProperties: .default,
        material: .default,
        mode: .dynamic
      ))
      milkModel?.generateCollisionShapes(recursive: true)
      milkModel?.physicsBody?.isAffectedByGravity = true
    } catch {
      print("Error Loading Milk Usdz File: \(error)")
    }
  }
  
  func getChicken() {
    if chickenModel == nil {
      loadChicken()
    } else {
      guard let cloneChicken = chickenModel?.clone(recursive: true) else { return }
      cloneChicken.position = getChickenPosition()
      if let animation = cloneChicken.availableAnimations.first {
        cloneChicken.playAnimation(animation.repeat(), transitionDuration: 0.6)
      }
      farmModel?.addChild(cloneChicken)
    }
  }
  
  func getCow() {
    if cowModel == nil {
      loadCowModel()
    } else {
      guard let cloneCow = cowModel?.clone(recursive: true) else { return }
      cloneCow.position = getCowPosition()
      if let animation = cloneCow.availableAnimations.first {
        cloneCow.playAnimation(animation.repeat(), transitionDuration: 0.6)
      }
      farmModel?.addChild(cloneCow)
    }
  }
  
  func generateGrassesOn(content: RealityViewCameraContent) {
    let rangesForX: [ClosedRange<Float>]  = [(-2.0...(-0.5)), (0.5...2.0)]
    let rangesForZ: [ClosedRange<Float>] =  [(-2.0...(-0.5)), (0.5...2.0)]
    for _ in 0..<10 {
      guard  let selectedRangeforX = rangesForX.randomElement(),
             let selectedRangeforZ = rangesForZ.randomElement() else { return }
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
      axe.position = [0.1,-0.2,-0.6]
      sickleModel?.scale = [0.0001,0.0001,0.0001]
      let rotationX = simd_quatf(angle: .pi/4, axis: [1, 0, 0])
      axe.transform.rotation = rotationX
      sickleModel?.removeFromParent()
      sickleModel = nil
      sickleModel = axe
      
    } catch {
      print("Error Loadig Axe Usdz File: \(error)")
    }
  }
  
  func loadTreesModel() {
    do {
      treeModel = try ModelEntity.loadModel(named: "tree")
      treeModel?.scale = [0.003,0.005,0.002]
    } catch {
      print("Error Loading  Grass Usdz File: \(error)")
    }
  }
  
  func generateTreesOn(content: RealityViewCameraContent) {
    let rangesForX: [ClosedRange<Float>]  = [(-3.0...(-0.5)), (0.5...3.0)]
    let rangesForZ: [ClosedRange<Float>] =  [(-3.0...(-0.5)), (0.5...3.0)]
    for _ in 0..<10 {
      guard let selectedRangeforX = rangesForX.randomElement(),
            let selectedRangeforZ = rangesForZ.randomElement() else { return }
      let x = Float.random(in: selectedRangeforX)
      let y: Float = 0.0
      let z = Float.random(in: selectedRangeforZ)
      guard let clone = treeModel?.clone(recursive: true) else { return }
      
      let bounds = treeModel?.visualBounds(relativeTo: nil)
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
  
}
