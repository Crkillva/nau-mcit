//
//  Dashboard.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 数据统计面板视图，为投保代理员提供决策，绩效管理。

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    //  显示在Bar chart的数据。
    @State private var stackedStatusChartData: [StatusChartData] = []
    @State private var stackedTypeChartData: [TypeChartData] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("数据统计面板")
                    .font(.title)
                
                Spacer()
                Image(systemName: "sum")
                Text("\(formVM.insuranceForms.count)")
            }
            Divider()
            GeometryReader { geometry in
                ScrollView {
                    Text("保单状态统计")
                    //  显示Bar chart view。
                    
                    StatusBarChart(stackedStatusChartData: $stackedStatusChartData)
                        .frame(height: geometry.size.height * 0.45)
                    
                    Divider()
                    
                    Text("保单产品类型统计")
                    //  显示Bar chart view。
                    
                    TypeBarChart(stackedTypeChartData: $stackedTypeChartData)
                        .frame(height: geometry.size.height * 0.45)
                }
            }
        }
        .onAppear(perform: {
            prepareStatusChartData()
            prepareTypeChartData()
        })
        .padding()
    }
    
    //  初始化stackedData。将查询结果items通过中间数据结构转化为统计数量数据结构stackedData。
    private func prepareStatusChartData() {
        guard !formVM.insuranceForms.isEmpty else {
            return
        }
        //  将items转化为[StatusChartData, Int]()字典数据结构。
        let itemCount = formVM.insuranceForms.reduce(into: [StatusBase: Int]()) { result, item in
            result[StatusBase(status: item.status, assessmentStatus: item.assessmentStatus), default: 0] += 1
        }
        //  将StatusChartData数据结构转化为[ChartData]。
        stackedStatusChartData = itemCount.map({
            StatusChartData(status: $0.key.status.rawValue, assessmentStatus: $0.key.assessmentStatus.rawValue, count: $0.value)
        })
        //  对stackedData排序，但在bar chart view中显示仍是随机。
        .sorted(by: { $0.status < $1.status && $0.assessmentStatus > $1.assessmentStatus })
    }
    
    private func prepareTypeChartData() {
        guard !formVM.insuranceForms.isEmpty else {
            return
        }
        //  将items转化为[TypeChartData, Int]()字典数据结构。
        let itemCount = formVM.insuranceForms.reduce(into: [TypeBase: Int]()) { result, item in
            let product = consultancyOptions.getProductById(id: item.productId)
            result[TypeBase(type: product?.type ?? InsuranceType.SuperType.others, subType: product?.subType ?? InsuranceType.SubType.others), default: 0] += 1
        }
        //  将StatusChartData数据结构转化为[ChartData]。
        stackedTypeChartData = itemCount.map({
            TypeChartData(type: $0.key.type.rawValue, subType: $0.key.subType.rawValue, count: $0.value)
        })
        //  对stackedData排序，但在bar chart view中显示仍是随机。
        .sorted(by: { $0.type < $1.type && $0.subType > $1.subType })
    }
}

#Preview {
    Dashboard()
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
