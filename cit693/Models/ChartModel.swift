//
//  ChartModel.swift
//  cit693
//
//  Created by crkillva on 2025-02-21.
//

import Foundation

//  定义用于group by统计Item的中间数据结构。
struct TypeBase: Hashable {
    var type: InsuranceType.SuperType
    var subType: InsuranceType.SubType
}

//  定义用于Chart View的数据结构。
struct TypeChartData: Identifiable {
    var id: String = UUID().uuidString
    var type: String
    var subType: String
    var count: Int
}

//  定义用于group by统计Item的中间数据结构。
struct StatusBase: Hashable {
    var status: FormStatus
    var assessmentStatus: AssessmentStatus
}

//  定义用于Chart View的数据结构。
struct StatusChartData: Identifiable {
    var id: String = UUID().uuidString
    var status: String
    var assessmentStatus: String
    var count: Int
}
