//
//  ShopView.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/11/25.
//


import SwiftUI
import SceneKit

struct ShopView: View {
  
  @Environment(\.dismiss) var dismiss
  @Binding var coins: Int
  @Binding var purcheseName: String
  let tools: [ShopItem] = [
    ShopItem(name: "Axe", price: 1000000, imageName: "axe.scn", description: "Coming Soon:)"),
  ]
  
  let animals: [ShopItem] = [
    ShopItem(name: "Chicken", price: 50, imageName: "chicken.scn", description: "Buy Chicken to get eggs and sell. Max 5 chickens."),
    ShopItem(name: "Cow", price: 100, imageName: "cow.scn", description: "Buy Cow to get milk. Max 5 cows"),
  ]
  
  let areas: [ShopItem] = [
    ShopItem(name: "Farm", price: 150, imageName: "farm.scn", description: "Buy Farm to get animals. Max 1 Farm."),
    ShopItem(name: "Market", price: 200, imageName: "market.scn", description: "Buy Market to sell your goods. Max 1 Market.")
    
  ]
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "creditcard.fill")
          .foregroundStyle(.yellow)
        Text("Coins: \(coins)")
          .font(.title)
          .bold()
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.1)))
      .padding()
      
      
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          SectionView(title: "🛠️ Tools") {
            ForEach(tools) { item in
              ShopItemView(item: item, coins: coins) {
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
                  
                  if coins >= item.price {
                    coins -= item.price
                    purcheseName = item.name
                    dismiss()
                  }
                }
              }
            }
          }
          SectionView(title: "🐔 Animals") {
            ForEach(animals) { item in
              ShopItemView(item: item, coins: coins) {
                DispatchQueue.global(qos: .background).async  {
                  if coins >= item.price {
                      coins -= item.price
                      purcheseName = item.name
                    dismiss()
                  }
                }
              }
            }
          }
          SectionView(title: "🏕️ Areas") {
            ForEach(areas) { item in
              ShopItemView(item: item, coins: coins) {
                DispatchQueue.global(qos: .background).async {
                  if coins >= item.price {
                    coins -= item.price
                    purcheseName = item.name
                    dismiss()
                  }
                }
              }
            }
          }
        }
        .padding()
      }
    }
    .background(Color(.systemGray6))
  }
  
}

struct SectionView<Content: View>: View {
  
  let title: String
  let content: () -> Content
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.title)
        .bold()
        .padding(.bottom, 5)
      content()
    }
  }
  
}

extension View {
  
  func thumbnail(for modelName: String, size: CGSize, time: TimeInterval = 0) -> UIImage? {
    let device = MTLCreateSystemDefaultDevice()
    let renderer = SCNRenderer(device: device, options: [:])
    renderer.autoenablesDefaultLighting = true
    guard let scene = SCNScene(named: modelName) else { return nil }
    renderer.scene = scene
    let image = renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
    return image
  }
  
}



#Preview {
  ShopView(coins: .constant(15), purcheseName: .constant(""))
}
