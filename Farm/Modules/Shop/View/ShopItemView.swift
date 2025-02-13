//
//  ShopItemView.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/13/25.
//

import SwiftUI

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
        .foregroundStyle(.gray)
      
      Text ("\(item.description)")
        .font(.subheadline)
        .foregroundStyle(.gray)
      Button(action: onBuy) {
        Text(coins >= item.price ? "Buy" : "Not Enough Coins")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(coins >= item.price ? Color.blue : Color.gray)
          .foregroundStyle(.white)
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
