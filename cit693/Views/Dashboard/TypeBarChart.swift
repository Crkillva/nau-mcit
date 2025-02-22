//
//  TypeBarChart.swift
//  cit693
//
//  Created by crkillva on 2025-02-21.
//
// 基于保单中保险产品类别的柱状图，数据来源于保单table

import SwiftUI
import Charts

struct TypeBarChart: View {
    //  定义bar chart显示所需数据，绑定到SwiftUI view。
    @Binding var stackedTypeChartData: [TypeChartData]
    
    var body: some View {
        Chart {
            ForEach(stackedTypeChartData) { shape in
                //  定义Type、count对，显示一维bar chart。
                BarMark(
                    x: .value("Type", shape.type),
                    y: .value("Count", shape.count)
                )
                //  追加SubType显示二维bar chart。
                .foregroundStyle(by: .value("SubType", shape.subType))
            }
        }
        //  修正barchart图例颜色与Item subType显示的颜色一致。
        .chartForegroundStyleScale([
            InsuranceType.SubType.termLife.rawValue: .green,
            InsuranceType.SubType.wholeLife.rawValue: .orange,
            InsuranceType.SubType.annuity.rawValue: .blue,
            InsuranceType.SubType.longTermCare.rawValue: .yellow,
            InsuranceType.SubType.children.rawValue: .purple,
            InsuranceType.SubType.criticalIllness.rawValue: .red,
            InsuranceType.SubType.comprehensiveAccident.rawValue: .teal,
            InsuranceType.SubType.others.rawValue: .gray
        ])
    }
}

#Preview {
    //  定义sample数据预览barchart效果，在实际App中不会生效。
    let stackedTypeChartData: [TypeChartData] = [
        .init(type: InsuranceType.SuperType.life.rawValue, subType: InsuranceType.SubType.termLife.rawValue, count: 4),
        .init(type: InsuranceType.SuperType.life.rawValue, subType: InsuranceType.SubType.wholeLife.rawValue, count: 7),
        .init(type: InsuranceType.SuperType.health.rawValue, subType: InsuranceType.SubType.criticalIllness.rawValue, count: 2),
        .init(type: InsuranceType.SuperType.health.rawValue, subType: InsuranceType.SubType.longTermCare.rawValue, count: 10),
        .init(type: InsuranceType.SuperType.savingsAndWealth.rawValue, subType: InsuranceType.SubType.annuity.rawValue, count: 6),
        .init(type: InsuranceType.SuperType.customized.rawValue, subType: InsuranceType.SubType.children.rawValue, count: 7),
        .init(type: InsuranceType.SuperType.accident.rawValue, subType: InsuranceType.SubType.comprehensiveAccident.rawValue, count: 3)
    ]
    TypeBarChart(stackedTypeChartData: .constant(stackedTypeChartData))
}
