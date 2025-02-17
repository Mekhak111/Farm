//
//  FarmRealityView.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/10/25.
//

import SwiftUI
import RealityKit

struct FarmRealityView: View {
  
  @StateObject var viewModel: FarmViewModel = FarmViewModel()
  
  @State private var cameraAnchor: AnchorEntity?
  @State private var content: RealityViewCameraContent?
  @State private var subs: [EventSubscription] = []
  @State private var animating = false
  @State private var coinsProgress: CGFloat = 0.0
  @State private var coins: Int = 10
  @State private var isShopVisible: Bool = false
  @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
  @State private var eggCount: Int = 0
  @State private var milkCount: Int = 0
  @State private var cowCount: Int = 0
  @State private var chickenCount: Int = 0
  @State var purchaseName: String = ""
  
  var body: some View {
    ZStack {
      realityContent
      frontView
    }
    .onAppear {
      viewModel.loadGrassModel()
      viewModel.loadSickleModel()
    }
    .onTapGesture {
      imitateSickle()
      cutGrass()
    }
    .sheet(isPresented: $isShopVisible) {
      ShopView(coins: $coins, purcheseName: $purchaseName)
    }
    .onReceive(timer) { _ in
      if !isShopVisible {
        if viewModel.chickenModel != nil {
          eggCount += chickenCount
        }
        if viewModel.cowModel != nil {
          milkCount += cowCount
        }
      }
    }
    .onChange(of: purchaseName) { _,_ in
      if purchaseName == "Axe" {
        viewModel.loadAxeModel()
        cameraAnchor?.addChild(viewModel.sickleModel ?? ModelEntity())
      } else if  purchaseName == "Chicken" {
        viewModel.getChicken()
        chickenCount += 1
        
      } else if purchaseName == "Farm" {
        viewModel.loadFarmModel()
        content?.add(viewModel.farmModel ?? ModelEntity())
      } else if purchaseName == "Cow" {
        viewModel.getCow()
        cowCount += 1
      } else if purchaseName == "Market" {
        viewModel.loadMarketModel()
        content?.add(viewModel.marketModel ?? ModelEntity())
      }
      purchaseName = ""
    }
    .onChange(of: isShopVisible) { oldValue, newValue in
      if newValue {
        viewModel.farmModel?.children.forEach({ child in
          child.stopAllAnimations()
        })
      } else {
        viewModel.farmModel?.children.forEach({ child in
          if let firstAnimation = child.availableAnimations.first {
            child.playAnimation(firstAnimation.repeat(), transitionDuration: 0.6)
          }
        })
      }
    }
    .gesture(
      DragGesture()
        .onChanged { value in
          guard let entity = viewModel.farmModel else { return }
          let translation = value.translation
          let newPosition = SIMD3<Float>(
            Float(translation.width) * 0.001,
            0,
            Float(translation.height) * -0.001
          )
          entity.position += newPosition
        }
    )
    .gesture(
      RotationGesture()
        .onChanged { value in
          guard let entity = viewModel.farmModel else { return }
          entity.transform.rotation = simd_quatf(
            angle: Float(value.radians),
            axis: [0, 1, 0]
          )
        }
    )
    .gesture(
      MagnificationGesture()
        .onChanged { value in
          guard let entity = viewModel.farmModel else { return }
          entity.scale = SIMD3<Float>(repeating: Float(value))
        }
    )
  }
  
}

extension FarmRealityView {
  
  private var frontView: some View {
    VStack {
      HStack {
        Button(action: {
          guard let egg = viewModel.eggModel else { return }
          coins += 2
          eggCount -= 1
          sellProduct(modelEnitity: egg, magnitude: 0.1)
        }) {
          Text("Sell 🥚: \(eggCount) ")
            .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .disabled(eggCount == 0)
        Button(action: {
          guard let milk = viewModel.milkModel else { return }
          coins += 4
          milkCount -= 1
          sellProduct(modelEnitity: milk)
        }) {
          Text("Sell 🍼: \(milkCount)")
            .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .disabled(milkCount == 0)
        
        Spacer()
        Button(action: {
          self.isShopVisible.toggle()
        }) {
          Image(systemName: "cart.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.yellow)
            .frame(maxWidth: 50, maxHeight: 50)
        }
      }
      .padding()
      Spacer()
      HStack {
        Image(.dollar)
          .resizable()
          .scaledToFit()
          .frame(maxWidth: 30, maxHeight: 30)
        Text("Coins: \(coins)")
          .foregroundStyle(Color.yellow)
          .font(.title)
          .bold()
      }
      .padding()
    }
  }
  
  private var realityContent: some View {
    RealityView { content in
      self.content = content
      let camera = AnchorEntity(.camera)
      camera.name = "Camera"
      DispatchQueue.main.async {
        cameraAnchor = camera
      }
      guard let sickle = viewModel.sickleModel else { return }
      viewModel.generateGrassesOn(content: content)
      camera.addChild(sickle)
      content.add(camera)
      content.camera = .spatialTracking
      let subscription =  content.subscribe(to: CollisionEvents.Ended.self, on: nil) { collision in
        print("Collision")
        if collision.entityA.name == "Grass" {
          collision.entityA.removeFromParent()
          coins += 15
        }
        if collision.entityB.name == "Grass" {
          collision.entityB.removeFromParent()
          coins +=  15
        }
        
        if self.content?.entities.count(where: {$0.name == "Grass"}) == 4 {
          guard let realityContent = self.content else { return }
          viewModel.generateGrassesOn(content: realityContent)
        }
      }
      DispatchQueue.main.async {
        subs.append(subscription)
      }
      
    }
    .ignoresSafeArea(.all)
  }
  
  private func cutGrass() {
    guard let sickle = viewModel.sickleModel else { return }
    if !animating {
      animating = true
      let originalTransform = sickle.transform
      var rotatedTransform = originalTransform
      rotatedTransform.rotation *= simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
      sickle.move(to: rotatedTransform, relativeTo: sickle.parent, duration: 0.3, timingFunction: .easeInOut)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        sickle.move(to: originalTransform, relativeTo: sickle.parent, duration: 0.5, timingFunction: .easeInOut)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          animating = false
        }
      }
    }
  }
  
  private func imitateSickle() {
    let imitation = ModelEntity(mesh: MeshResource.generateBox(size: 0.001), materials: [SimpleMaterial(color: .clear, isMetallic: false)])
    imitation.components.set(PhysicsBodyComponent(
      massProperties: .default,
      material: .default,
      mode: .dynamic
    ))
    guard let sickle = viewModel.sickleModel else { return }
    imitation.position = sickle.position(relativeTo: nil)
    imitation.physicsBody?.isAffectedByGravity = true
    imitation.generateCollisionShapes(recursive: true)
    content?.add( imitation)
  }
  
  func getCameraForwardVector(camera: Entity) -> SIMD3<Float> {
    let cameraOrientation = camera.orientation(relativeTo: nil)
    let forward = cameraOrientation.act(SIMD3<Float>(0, 0, -1))
    return normalize(forward)
  }
  
  func sell(from position: SIMD3<Float>, model: ModelEntity) -> ModelEntity {
    let clone = model.clone(recursive: true)
    clone.position = position
    return clone
  }
  
  func applyForce(to entity: ModelEntity, direction: SIMD3<Float>, magnitude: Float) {
    guard let _ = entity.physicsBody else {
      print("Physics body not found.")
      return
    }
    let force = direction * magnitude
    entity.addForce(force, relativeTo: entity.parent)
  }
  
  func sellProduct(modelEnitity: ModelEntity, magnitude: Float = 0.08) {
    guard let content = content else { return }
    let magnitude: Float = magnitude
    guard let cameraAnchor, let sickle = viewModel.sickleModel else { return }
    let pos = getCameraForwardVector(camera: cameraAnchor)
    let model = sell(from: sickle.position(relativeTo: nil), model: modelEnitity)
    
    content.add(model)
    applyForce(to: model, direction: pos, magnitude: magnitude)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      model.removeFromParent()
    }
  }
  
  
}

#Preview {
  FarmRealityView()
}
