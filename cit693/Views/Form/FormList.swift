//
//  FormList.swift
//  cit693
//
//  Created by crkillva on 2025-02-12.
//
// 保单列表视图，数据源于服务器Form table

import SwiftUI
import SwiftData

struct FormList: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    //  用于查询所有Item。
    @Query private var items: [InsuranceForm]
    //  用于记录选择的SuperType选择器的值，默认为ALL。
    @State private var filterStatus: String = ConstantValue.all
    //  用于记录选择的SubType选择器的值，默认为ALL。
    @State private var filterAssessmentStatus: String = ConstantValue.all
    
    //  用于显示item list中的数据，使用选择器的值对所有item进行匹配过滤。
    var filteredItems: [InsuranceForm] {
        return formVM.insuranceForms.filter { item in
            funcFilterItem(item: item)
        }
        .reversed()
    }

    var body: some View {
        //  使用NvagationSplitView结合使用NavigationLink使得列表view和item view之间可相互导航。
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("保单列表")
                        .font(.title)
                    Spacer()
                    
                    Button {
                        Task {
                            try await formVM.loadForms()
                            print("loaded forms")
                        }
                    } label: {
                        Text("\(Image(systemName: "arrow.clockwise.circle"))刷新")
                    }
                }
                
                Divider()
                
                //  显示item总数，过滤选择器和列表的编辑按钮。
                HStack {
                    Image(systemName: "sum")
                    Text("\(filteredItems.count)")
                    
                    Divider().frame(height: 20)
                    
                    //  过滤status的选择器。
                    Label("保单状态", systemImage: "arrow.3.trianglepath")
                    Picker("Status", selection: $filterStatus) {
                        Text(ConstantValue.all).tag(ConstantValue.all)
                        ForEach(FormStatus.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Divider().frame(height: 20)
                    
                    //  过滤assessmentStatus的选择器。
                    Label("评估状态", systemImage: "arrow.3.trianglepath")
                    Picker("AssessmentStatus", selection: $filterAssessmentStatus) {
                        Text(ConstantValue.all).tag(ConstantValue.all)
                        ForEach(AssessmentStatus.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                List {
                    //  每个item可导航到item的主控视图，可查看item和执行编辑操作。
                    ForEach(filteredItems) {item in
                        NavigationLink {
                            toFormHostView(insuranceForm: item)
                        } label: {
                            //  设计item在列表中的显示信息
                            VStack {
                                HStack {
                                    Text("#\(item.id)")
                                    Divider()
                                    switch item.status {
                                    case FormStatus.submitted:
                                        Text(item.status.rawValue)
                                            .foregroundColor(.orange)
                                    case FormStatus.approved:
                                        Text(item.status.rawValue)
                                            .foregroundColor(.green)
                                    case FormStatus.rejected:
                                        Text(item.status.rawValue)
                                            .foregroundColor(.red)
                                    default:
                                        Text(item.status.rawValue)
                                            .foregroundColor(.gray)
                                    }
                                    Divider()
                                    switch item.assessmentStatus {
                                    case AssessmentStatus.passed:
                                        Text(item.assessmentStatus.rawValue)
                                            .foregroundColor(.green)
                                    case AssessmentStatus.failed:
                                        Text(item.assessmentStatus.rawValue)
                                            .foregroundColor(.red)
                                    default:
                                        Text(item.assessmentStatus.rawValue)
                                            .foregroundColor(.orange)
                                    }
        
                                    Spacer()
                                }
                                HStack {
                                    Text("投保人: \(item.policyholder)")
                                    Divider()
                                    Text("产品编号#\(item.productId)")
                                    Spacer()
                                }
                                
                            }
                        }
                    }
                }
                //  添加对数据执行过滤和删除数据时的动画效果。
                .animation(.default, value: filteredItems)
                
            }
            .padding()
            .onAppear(perform: {
                Task {
                    try await formVM.loadForms()
                    print("loaded forms")
                }
            })
        }
    }
    
    //  定义item过滤方法，返回Bool类型判断结果。
    private func funcFilterItem(item: InsuranceForm) -> Bool {
        var filteredStatus: Bool
        var filteredAssessmentStatus: Bool
        var filteredUser = false

        // 客户只能访问自己的表单，投保代理员则可看访问保单
        guard let user = auth.currentUser else {
            return filteredUser
        }
        if user.role == UserRole.agent {
            filteredUser = true
        } else {
            filteredUser = item.userId == user.id
        }
        
        //  使用选择器的值匹配item的importance。
        if filterStatus == ConstantValue.all {
            filteredStatus = FormStatus.allCases.contains(item.status)
        } else {
            filteredStatus = item.status.rawValue == filterStatus
        }
        //  使用选择器的值匹配item的status。
        if filterAssessmentStatus == ConstantValue.all {
            filteredAssessmentStatus = AssessmentStatus.allCases.contains(item.assessmentStatus)
        } else {
            filteredAssessmentStatus = item.assessmentStatus.rawValue == filterAssessmentStatus
        }
        return filteredUser && filteredStatus && filteredAssessmentStatus
    }
    
    //  定义显示或编辑item的主控视图的方法，返回ItemHost view。
    private func toFormHostView(@State insuranceForm: InsuranceForm) -> FormHost {
        FormHost(insuranceForm: $insuranceForm)
    }
    
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    FormList()
        .modelContainer(for: InsuranceForm.self, inMemory: true)
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
