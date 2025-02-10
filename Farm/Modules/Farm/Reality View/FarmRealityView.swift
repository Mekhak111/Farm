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
  @State var cameraAnchor: AnchorEntity?
  @State var content: RealityViewCameraContent?
  
  @State var animating = false
  var body: some View {
    RealityView { content in

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
    }
    .onAppear {
      viewModel.loadGrasModel()
      viewModel.loadSickleModel()
    }
    .onTapGesture {
      cutGrass()
    }
  }
}

extension FarmRealityView {
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
}

#Preview {
  FarmRealityView()
}
