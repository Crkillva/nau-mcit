//
//  solutionModel.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 定义推荐方案的数据类型，及对应的enum，DTO model

import Foundation
import SwiftData


@Model
class SolutionItem {
    var id: String = UUID().uuidString
    var productId: String
    var matchScore: Double
    var reason: String
    
    init(productId: String, matchScore: Double, reason: String) {
        self.productId = productId
        self.matchScore = matchScore
        self.reason = reason
    }
    
    init(dto: SolutionItemDTO) {
        self.productId = dto.productId
        self.matchScore = dto.matchScore
        self.reason = dto.reason
    }

}

// DTO for model conversion
class SolutionItemDTO: Codable {
    var productId: String
    var matchScore: Double
    var reason: String
}
