//
//  StatusBarChart.swift
//  cit693
//
//  Created by crkillva on 2025-02-21.
//
// 基于保单处理状态的柱状图，数据来源于保单table

import SwiftUI
import Charts

struct StatusBarChart: View {
    //  定义bar chart显示所需数据，绑定到SwiftUI view。
    @Binding var stackedStatusChartData: [StatusChartData]
    
    var body: some View {
        Chart {
            ForEach(stackedStatusChartData) { shape in
                //  定义Status、count对，显示一维bar chart。
                BarMark(
                    x: .value("Status", shape.status),
                    y: .value("Count", shape.count)
                )
                //  追加importance显示二维bar chart。
                .foregroundStyle(by: .value("AssessmentStatus", shape.assessmentStatus))
            }
        }
        //  修正barchart图例颜色与Item importance显示的颜色一致。
        .chartForegroundStyleScale([
            AssessmentStatus.passed.rawValue: .green,
            AssessmentStatus.failed.rawValue: .red,
            AssessmentStatus.pending.rawValue: .orange
        ])
    }
}

#Preview {
    //  定义sample数据预览barchart效果，在实际App中不会生效。
    let stackedStatusChartData: [StatusChartData] = [
        .init(status: FormStatus.drafted.rawValue, assessmentStatus: AssessmentStatus.pending.rawValue, count: 4),
        .init(status: FormStatus.submitted.rawValue, assessmentStatus: AssessmentStatus.pending.rawValue, count: 3),
        .init(status: FormStatus.submitted.rawValue, assessmentStatus: AssessmentStatus.passed.rawValue, count: 4),
        .init(status: FormStatus.approved.rawValue, assessmentStatus: AssessmentStatus.passed.rawValue, count: 10),
        .init(status: FormStatus.rejected.rawValue, assessmentStatus: AssessmentStatus.failed.rawValue, count: 2)
    ]
    StatusBarChart(stackedStatusChartData: .constant(stackedStatusChartData))
}
