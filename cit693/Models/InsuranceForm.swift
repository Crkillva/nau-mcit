//
//  InsuranceForm.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 定义保单数据类型，及对应的enum，DTO model

import Foundation
import SwiftData

//  定义对Item数据操作（新增，编辑，查看）的模式切换。
enum HostMode: String, CaseIterable, Identifiable, Codable {
    case edit, view, error
    
    var id: String { rawValue }
}

enum FormStatus: String, Codable, Identifiable, CaseIterable {
    case drafted = "编辑状态"
    case submitted = "等待初审"
    case approved = "初审通过"
    case rejected = "条件不符"
    
    var id: String { rawValue }
    
    static let rawValueMap: [String: FormStatus] = {
        Dictionary(uniqueKeysWithValues: FormStatus.allCases.map { (String(describing: $0), $0) })
    }()
    
    static func fromRawValue(_ value: String) -> FormStatus {
        return rawValueMap[value] ?? FormStatus.drafted
    }
}

enum AssessmentStatus: String, Codable, Identifiable, CaseIterable {
    case passed = "通过"
    case failed = "未通过"
    case pending = "未评估"
    
    var id: String { rawValue }
    
    static let rawValueMap: [String: AssessmentStatus] = {
        Dictionary(uniqueKeysWithValues: AssessmentStatus.allCases.map { (String(describing: $0), $0) })
    }()
    
    static func fromRawValue(_ value: String) -> AssessmentStatus {
        return rawValueMap[value] ?? AssessmentStatus.pending
    }
}

@Model
class InsuranceForm {
    var id: String = UUID().uuidString
    var productId: String
    var userId: String
    var policyholder: String
    var insured: String
    var premium: Double
    var assessmentStatus: AssessmentStatus
    var status: FormStatus
    var date: Date
    var reviewDate: Date
    var reviewerId: String
    var comment: String
    
    
    init(productId: String, userId: String) {
        self.productId = productId
        self.userId = userId
        self.premium = 0
        self.assessmentStatus = AssessmentStatus.pending
        self.status = FormStatus.drafted
        self.policyholder = ""
        self.insured = ""
        self.date = Date()
        self.reviewDate = Date()
        self.reviewerId = ""
        self.comment = ""
    }
    
    init(dict: [String: Any]) {
        let id = dict["Id"] as? Int
        self.id = id?.description ?? UUID().uuidString
        self.productId = dict["productId"] as? String ?? ""
        self.userId = dict["userId"] as? String ?? ""
        self.policyholder = dict["policyholder"] as? String ?? ""
        self.insured = dict["insured"] as? String ?? ""
        self.premium = dict["premium"] as? Double ?? 0
        self.assessmentStatus = AssessmentStatus.fromRawValue(dict["assessmentStatus"] as? String ?? "")
        self.status = FormStatus.fromRawValue(dict["status"] as? String ?? "")
        self.date = dict["date"] as? Date ?? Date()
        self.reviewDate = dict["reviewDate"] as? Date ?? Date()
        self.reviewerId = dict["reviewerId"] as? String ?? ""
        self.comment = dict["comment"] as? String ?? ""
        
    }
    
    init(dto: InsuranceFormDTO) {
        self.id = dto.id.description
        self.productId = dto.productId
        self.userId = dto.userId
        self.policyholder = dto.policyholder
        self.insured = dto.insured
        self.premium = dto.premium
        self.assessmentStatus = AssessmentStatus.fromRawValue(dto.assessmentStatus)
        self.status = FormStatus.fromRawValue(dto.status)
        self.date = formateDate(dto.date)
        self.reviewDate = formateDate(dto.reviewDate)
        self.reviewerId = dto.reviewerId
        self.comment = dto.comment
    }

}

// DTO for http request body
class InsuranceFormRequestDTO: Codable {
    var productId: String
    var userId: String
    var policyholder: String
    var insured: String
    var premium: Double
    var assessmentStatus: String
    var status: String
    var date: String
    var reviewDate: String
    var reviewerId: String
    var comment: String
    
    init(productId: String, userId: String, policyholder: String, insured: String, premium: Double, assessmentStatus: String, status: String, date: String, reviewDate: String, reviewerId: String, comment: String) {
        self.productId = productId
        self.userId = userId
        self.policyholder = policyholder
        self.insured = insured
        self.premium = premium
        self.assessmentStatus = assessmentStatus
        self.status = status
        self.date = date
        self.reviewDate = reviewDate
        self.reviewerId = reviewerId
        self.comment = comment
    }
}

// DTO for http reqponse body
class InsuranceFormDTO: InsuranceFormRequestDTO {
    var id: Int
    
    init(id: Int, productId: String, userId: String, policyholder: String, insured: String, premium: Double, assessmentStatus: String, status: String, date: String, reviewDate: String, reviewerId: String, comment: String) {
        self.id = id
        super.init(productId: productId, userId: userId, policyholder: policyholder, insured: insured, premium: premium, assessmentStatus: assessmentStatus, status: status, date: date, reviewDate: reviewDate, reviewerId: reviewerId, comment: comment)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        
        // 调用父类的 init(from:)
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
    }
    
}
