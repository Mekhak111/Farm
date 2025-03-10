//
//  ImmersiveView.swift
//  FarmVision
//
//  Created by Mekhak Ghapantsyan on 2/25/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct FarmRealityView: View {
  
  @Environment(\.openWindow) var openwindow
  
  @StateObject var viewModel: FarmViewModel = FarmViewModel()
  
  @State private var handAnchor: AnchorEntity?
  @State private var content: RealityViewContent?
  @State private var subs: [EventSubscription] = []
  @State private var animating = false
  
  @State private var isShopVisible: Bool = false
  @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
  @State private var eggCount: Int = 0
  @State private var milkCount: Int = 0
  @State private var cheaseCount: Int = 10
  @State private var cowCount: Int = 0
  @State private var chickenCount: Int = 0
  @Binding var purchaseName: String
  @Binding var coins: Int
  
  
  var body: some View {
    realityContent
      .onAppear {
        viewModel.loadGrassModel()
        viewModel.loadFarmModel()
        viewModel.loadSickleModel()
      }
    
    //MARK: - implement diferently
    //      .onTapGesture {
    //        imitateSickle()
    //        cutGrass()
    //      }
      .onReceive(timer) { _ in
        //        if !isShopVisible {
        if viewModel.chickenModel != nil {
          eggCount += chickenCount
        }
        if viewModel.cowModel != nil {
          milkCount += cowCount
        }
        //        }
      }
      .onChange(of: purchaseName) { _,_ in
        if purchaseName == "Axe" {
          viewModel.loadAxeModel()
          handAnchor?.addChild(viewModel.sickleModel ?? ModelEntity())
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
        } else if purchaseName == "Chease Factory" {
          viewModel.loadFactoryModel()
          guard let factory = viewModel.factoryModel else { return }
          factory.position = [3,1.3,-5]
          factory.components.set(InputTargetComponent())
          factory.components.set(GestureComponent())
          factory.generateCollisionShapes(recursive: true)
          content?.add(factory)
        }
        purchaseName = ""
      }
  }
  
}

extension FarmRealityView {
  
  private var frontView: Attachment<some View>  {
    Attachment(id: "Shop") {
      VStack {
        HStack {
          Button(action: {
            //            guard let egg = viewModel.eggModel else { return }
            coins += eggCount * 2
            eggCount = 0
            //            sellProduct(modelEnitity: egg, magnitude: 0.1)
          }) {
            Text("Sell 🥚 : \(eggCount) ")
              .font(.headline)
          }
          .buttonStyle(.borderedProminent)
          .disabled(eggCount == 0)
          Button(action: {
            //            guard let milk = viewModel.milkModel else { return }
            coins += milkCount * 4
            milkCount = 0
            //            sellProduct(modelEnitity: milk)
          }) {
            Text("Sell 🍼: \(milkCount)")
              .font(.headline)
          }
          .buttonStyle(.borderedProminent)
          .disabled(milkCount == 0)
          Button(action: {
            guard let cheaseModel = viewModel.cheaseModel else { return }
            coins += 10
            cheaseCount -= 1
            sellProduct(modelEnitity: cheaseModel,magnitude: 0.05)
          }) {
            Text("Sell 🧀: \(cheaseCount)")
              .font(.headline)
          }
          .buttonStyle(.borderedProminent)
          .disabled(cheaseCount == 0)
          Button(action: {
            openwindow.callAsFunction(id: "Shop")
          }) {
            Image(systemName: "cart.fill")
              .resizable()
              .scaledToFit()
              .foregroundStyle(Color.yellow)
              .frame(maxWidth: 50, maxHeight: 50)
          }
        }
        .padding()
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
      }.glassBackgroundEffect()
    }
  }
  
  private var realityContent: some View {
    RealityView { content, attachments in
      self.content = content
      let camera = AnchorEntity(.hand(.right, location: .aboveHand))
      let floor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: .init(x: 2, y: 2)), trackingMode: .once)

      camera.name = "Camera"
      DispatchQueue.main.async {
        handAnchor = camera
      }
      guard let sickle = viewModel.sickleModel else { return }
      guard let farm = viewModel.farmModel else { return }
      viewModel.generateGrassesOn(content: content)
      farm.components.set(InputTargetComponent())
      farm.components.set(GestureComponent())
      farm.generateCollisionShapes(recursive: true)
      if let shopAttachment = attachments.entity(for: "Shop") {
        shopAttachment.position = [2, 1.6,-3 ]
        shopAttachment.scale = [3,3,3]
        //        shopAttachment.setPosition([2,-2,0], relativeTo: farm)
        content.add(shopAttachment)
      }
      
      farm.position = [0,1.3,-5]
      content.add(farm)
      camera.addChild(sickle)
      content.add(camera)
      
      let subscription =  content.subscribe(to: CollisionEvents.Ended.self, on: nil) { collision in
        print("Collision A:\(collision.entityA) B:\(collision.entityB)")
        if collision.entityA.name == "Grass" {
          collision.entityA.removeFromParent()
          coins += 15
        }
        if collision.entityB.name == "Grass" {
          collision.entityB.removeFromParent()
          coins +=  15
        }
        
        if (collision.entityA.name == "Factory" && collision.entityB.name == "Milk")
        {
          print("Generate Chease")
          let pos = collision.entityB.position(relativeTo: nil)
          collision.entityB.removeFromParent()
          if let anim = viewModel.factoryModel?.availableAnimations.first {
            viewModel.factoryModel?.playAnimation(anim.repeat(count: 3), transitionDuration: 1.0)
          }
          getChease(position: pos)
        }
        
        if self.content?.entities.count(where: {$0.name == "Grass"}) == 4 {
          guard let realityContent = self.content else { return }
          viewModel.generateGrassesOn(content: realityContent)
        }
      }
      DispatchQueue.main.async {
        subs.append(subscription)
      }
      
    } update: { content, attachments in
      
    } attachments: {
      frontView
    }
    .installGestures()
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
  
  func getCameraBackwardVector(camera: Entity) -> SIMD3<Float> {
    let cameraOrientation = camera.orientation(relativeTo: nil)
    let forward = cameraOrientation.act(SIMD3<Float>(0, 0, 1))
    return normalize(forward)
  }
  
  func makeModel(from position: SIMD3<Float>, model: ModelEntity) -> ModelEntity {
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
    guard let handAnchor, let sickle = viewModel.sickleModel else { return }
    let pos = getCameraForwardVector(camera: handAnchor)
    let model = makeModel(from: sickle.position(relativeTo: nil), model: modelEnitity)
    
    content.add(model)
    applyForce(to: model, direction: pos, magnitude: magnitude)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      model.removeFromParent()
    }
  }
  
  func getChease(position: SIMD3<Float>) {
    guard let content else { return }
    guard let handAnchor else { return }
    let pos = getCameraBackwardVector(camera: handAnchor)
    let chease = makeModel(from: position, model: viewModel.cheaseModel!)
    content.add(chease)
    applyForce(to: chease, direction: pos, magnitude: 0.05)
    cheaseCount += 1
  }
  
}

#Preview(immersionStyle: .full) {
  FarmRealityView(purchaseName: .constant("Name"), coins: .constant(100))
    .environment(AppModel())
}
