//
//  ShopView.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/11/25.
//


import SwiftUI
import SceneKit

struct ShopView: View {
  
  @Binding var coins: Int
  @Binding var purcheseName: String
  let tools: [ShopItem] = [
    ShopItem(name: "Axe", price: 10, imageName: "axe.scn"),
    ShopItem(name: "Chainsaw", price: 50, imageName: "chainsaw.scn")
  ]
  
  let animals: [ShopItem] = [
    ShopItem(name: "Chicken", price: 100, imageName: "chicken.scn")
  ]
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "creditcard.fill")
          .foregroundColor(.yellow)
        Text("Coins: \(coins)")
          .font(.title)
          .bold()
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.1)))
      .padding(.horizontal)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          SectionView(title: "🛠️ Tools") {
            ForEach(tools) { item in
              ShopItemView(item: item, coins: coins) {
                if coins >= item.price {
                  withAnimation {
                    coins -= item.price
                    purcheseName = item.name
                  }
                }
                
              }
            }
          }
          SectionView(title: "🐔 Animals") {
            ForEach(animals) { item in
              ShopItemView(item: item, coins: coins) {
                if coins >= item.price {
                  withAnimation {
                    coins -= item.price
                    purcheseName = item.name
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


struct ShopItemView: View {
  
  let item: ShopItem
  let coins: Int
  let onBuy: () -> Void
  
  var body: some View {
    VStack {
      Image(uiImage: thumbnail(for: item.imageName, size: CGSize(width: 150, height: 150), time: 0.0) ?? UIImage())
        .resizable()
        .scaledToFit()
        .frame(height: 100)
        .padding()
      
      Text(item.name)
        .font(.title2)
        .bold()
      
      Text("\(item.price) Coins")
        .font(.headline)
        .foregroundColor(.gray)
      
      Button(action: onBuy) {
        Text(coins >= item.price ? "Buy" : "Not Enough Coins")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(coins >= item.price ? Color.blue : Color.gray)
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(radius: 5)
      }
      .disabled(coins < item.price)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(15)
    .shadow(radius: 5)
    .opacity(coins >= item.price ? 1.0 : 0.5)
  }
  
}

func thumbnail(for modelName: String, size: CGSize, time: TimeInterval = 0) -> UIImage? {
  let device = MTLCreateSystemDefaultDevice()
  let renderer = SCNRenderer(device: device, options: [:])
  renderer.autoenablesDefaultLighting = true
  guard let scene = SCNScene(named: modelName) else { return nil }
  renderer.scene = scene
  let image = renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
  return image
}

#Preview {
  ShopView(coins: .constant(15), purcheseName: .constant(""))
}
