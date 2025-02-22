//
//  InsuranceProduct.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 定义保险产品数据类型，及对应的enum，DTO model

import Foundation
import SwiftData

enum InsuranceType: String, Codable, CaseIterable {
    case personal = "人身保险"
    case unknown = "未知类型"
    
    var id: String { rawValue }
    
    static let rawValueMap: [String: InsuranceType] = {
        Dictionary(uniqueKeysWithValues: InsuranceType.allCases.map { ($0.rawValue, $0) })
    }()
    
    static func fromRawValue(_ value: String) -> InsuranceType {
        return rawValueMap[value] ?? .unknown
    }
    
    enum SuperType: String, Codable, Identifiable, CaseIterable {
        case life = "人寿保险"
        case health = "健康保险"
        case accident = "意外保险"
        case savingsAndWealth = "储蓄理财型保险"
        case customized = "特殊人群定制型保险"
        case others = "行业创新险种"
        
        var id: String { rawValue }
        
        static let rawValueMap: [String: SuperType] = {
            Dictionary(uniqueKeysWithValues: SuperType.allCases.map { ($0.rawValue, $0) })
        }()
        
        static func fromRawValue(_ value: String) -> SuperType {
            return rawValueMap[value] ?? SuperType.others
        }
    }
    
    enum SubType: String, Codable, Identifiable, CaseIterable {
        case termLife = "定期寿险"
        case wholeLife = "终身寿险"
        case endowment = "两全保险"
        case criticalIllness = "重疾保险"
        case medical = "医疗保险"
        case disabilityIncome = "失能收入保险"
        case longTermCare = "长期护理保险"
        case comprehensiveAccident = "综合意外保险"
        case specificAccident = "特定场景意外保险"
        case annuity = "年金保险"
        case investmentLinked = "投资连结保险"
        case children = "儿童保险包"
        case women = "女性专属保险"
        case elderCancer = "老年人防癌险"
        case others = "新型险种"
        
        var id: String { rawValue }
        
        static let rawValueMap: [String: SubType] = {
            Dictionary(uniqueKeysWithValues: SubType.allCases.map { ($0.rawValue, $0) })
        }()
        
        static func fromRawValue(_ value: String) -> SubType {
            return rawValueMap[value] ?? SubType.others
        }
        
    }
}

@Model
class InsuranceProduct {
    var id: String
    var name: InsuranceType
    var type: InsuranceType.SuperType
    var subType: InsuranceType.SubType
    var definition: String
    var characterization: String
    var coverageAmountMin: Double
    var coverageAmountMax: Double
    var premiumMin: Double
    var premiumMax: Double
    var eligibleAgeMin: Int
    var eligibleAgeMax: Int
    var riskCoefficient: Double
    
    init() {
        self.id = UUID().uuidString
        self.name = InsuranceType.unknown
        self.type = InsuranceType.SuperType.others
        self.subType = InsuranceType.SubType.others
        self.definition = ""
        self.characterization = ""
        self.coverageAmountMin = 0
        self.coverageAmountMax = 0
        self.premiumMin = 0
        self.premiumMax = 0
        self.eligibleAgeMin = 0
        self.eligibleAgeMax = 0
        self.riskCoefficient = 0
        
    }
    
    init(dict: [String: Any]) {
        let id = dict["Id"] as? Int
        self.id = id?.description ?? UUID().uuidString
        self.name = InsuranceType.fromRawValue(dict["name"] as? String ?? "")
        self.type = InsuranceType.SuperType.fromRawValue(dict["type"] as? String ?? "")
        self.subType = InsuranceType.SubType.fromRawValue(dict["subType"] as? String ?? "")
        self.definition = dict["definition"] as? String ?? ""
        self.characterization = dict["characterization"] as? String ?? ""
        self.coverageAmountMin = dict["coverageAmountMin"] as? Double ?? 0
        self.coverageAmountMax = dict["coverageAmountMax"] as? Double ?? 0
        self.premiumMin = dict["premiumMin"] as? Double ?? 0
        self.premiumMax = dict["premiumMax"] as? Double ?? 0
        self.eligibleAgeMin = dict["eligibleAgeMin"] as? Int ?? 0
        self.eligibleAgeMax = dict["eligibleAgeMax"] as? Int ?? 0
        self.riskCoefficient = dict["riskCoefficient"] as? Double ?? 0
    }
    
    init(dto: InsuranceProductDTO) {
        self.id = dto.id.description
        self.name = InsuranceType.fromRawValue(dto.name)
        self.type = InsuranceType.SuperType.fromRawValue(dto.type)
        self.subType = InsuranceType.SubType.fromRawValue(dto.subType)
        self.definition = dto.definition
        self.characterization = dto.characterization
        self.coverageAmountMin = dto.coverageAmountMin
        self.coverageAmountMax = dto.coverageAmountMax
        self.premiumMin = dto.premiumMin
        self.premiumMax = dto.premiumMax
        self.eligibleAgeMin = dto.eligibleAgeMin
        self.eligibleAgeMax = dto.eligibleAgeMax
        self.riskCoefficient = dto.riskCoefficient
    }
    
    func toString() -> String {
        var text = "(产品编号: \(self.id)"
        text += ", 保险类型1: \(self.name)"
        text += ", 保险类型2: \(self.type)"
        text += ", 细分险种: \(self.subType)"
        text += ", 定义说明: \(self.definition)"
        text += ", 适用情况: \(self.characterization)"
        text += ", 最低赔付额: \(self.coverageAmountMin.description)"
        text += ", 最高赔付额: \(self.coverageAmountMax.description)"
        text += ", 最低保费: \(self.premiumMin.description)"
        text += ", 最高保费: \(self.premiumMax.description)"
        text += ", 适用年龄下限: \(self.eligibleAgeMin.description)"
        text += ", 适用年龄上限: \(self.eligibleAgeMax.description)"
        text += ", 风险系数: \(self.riskCoefficient.description)"
        return text + ")"
    }
    
}

// DTO for http response body
class InsuranceProductDTO: Codable {
    var id: Int
    var name: String
    var type: String
    var subType: String
    var definition: String
    var characterization: String
    var coverageAmountMin: Double
    var coverageAmountMax: Double
    var premiumMin: Double
    var premiumMax: Double
    var eligibleAgeMin: Int
    var eligibleAgeMax: Int
    var riskCoefficient: Double

    init(id: Int, name: String, type: String, subType: String, definition: String, characterization: String, coverageAmountMin: Double, coverageAmountMax: Double, premiumMin: Double, premiumMax: Double, eligibleAgeMin: Int, eligibleAgeMax: Int, riskCoefficient: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.subType = subType
        self.definition = definition
        self.characterization = characterization
        self.coverageAmountMin = coverageAmountMin
        self.coverageAmountMax = coverageAmountMax
        self.premiumMin = premiumMin
        self.premiumMax = premiumMax
        self.eligibleAgeMin = eligibleAgeMin
        self.eligibleAgeMax = eligibleAgeMax
        self.riskCoefficient = riskCoefficient
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name
        case type
        case subType
        case definition
        case characterization
        case coverageAmountMin
        case coverageAmountMax
        case premiumMin
        case premiumMax
        case eligibleAgeMin
        case eligibleAgeMax
        case riskCoefficient
    }
}
