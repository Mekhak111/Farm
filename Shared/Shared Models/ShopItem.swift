//
//  ShopItem.swift
//  Farm
//
//  Created by Mekhak Ghapantsyan on 2/11/25.
//

import Foundation

struct ShopItem: Identifiable {
  
  let id = UUID()
  let name: String
  let price: Int
  let imageName: String
  let description: String
  
}
