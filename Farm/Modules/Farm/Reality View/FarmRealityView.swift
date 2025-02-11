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
  @State private var subs: EventSubscription?
  @State private var animating = false
  @State private var coinsProgress: CGFloat = 0.0
  @State private var coins: Int = 0
  @State var isShopVisible: Bool = false
  @State var purchaseName: String = ""
  
  var body: some View {
    ZStack {
      realityContent
      frontView
    }
    .onAppear {
      viewModel.loadGrasModel()
      viewModel.loadSickleModel()
    }
    .onTapGesture {
      imitateSickle()
      cutGrass()
    }
    .sheet(isPresented: $isShopVisible) {
      ShopView(coins: $coins, purcheseName: $purchaseName)
    }
    //MARK: - Implement tool change
    .onChange(of: purchaseName) { _, _ in
      //      viewModel.loadAxeModel()
    }
    
  }
}

extension FarmRealityView {
  
  private var frontView: some View {
    VStack {
      Spacer()
      HStack {
        Image(.dollar)
          .resizable()
          .scaledToFit()
        ProgressBarView(progress: $coinsProgress, colors: [.green, .yellow])
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
    } update: { content in
      DispatchQueue.main.async {
        guard let content = self.content else { return }
        subs =  content.subscribe(to: CollisionEvents.Ended.self, on: nil) { collision in
          if collision.entityA.name == "Grass" {
            collision.entityA.removeFromParent()
            coinsProgress += 0.1
            coins += 1
          }
          if collision.entityB.name == "Grass" {
            collision.entityB.removeFromParent()
            coinsProgress +=  0.1
            coins +=  1
          }
          if coins == 10 {
            withAnimation(.easeOut) {
              isShopVisible = true
            }
          }
        }
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
    imitation.position = viewModel.sickleModel!.position(relativeTo: nil)
    imitation.physicsBody?.isAffectedByGravity = true
    imitation.generateCollisionShapes(recursive: true)
    content?.add( imitation)
  }
  
}

#Preview {
  FarmRealityView()
}
