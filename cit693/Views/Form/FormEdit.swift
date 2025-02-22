//
//  FormEdit.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 更新保单数据视图，根据用户的权限提供不同的数据填写表单

import SwiftUI

struct FormEdit: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    @Binding var insuranceForm: InsuranceForm
    var insuranceProduct: InsuranceProduct {
        consultancyOptions.getProductById(id: insuranceForm.productId) ?? InsuranceProduct()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            Text("保单更新")
                .font(.title2)
            Divider()
            
            HStack {
                Text("编号:")
                Spacer()
                Text(insuranceForm.id)
            }
            
            // 投保代理员审批表单
            if let user = auth.currentUser, user.role == UserRole.agent {
                Text("处理状况")
                    .font(.headline)
            
                HStack {
                    Text("处理状态:")
                    Spacer()
                    switch insuranceForm.status {
                    case FormStatus.submitted:
                        Text(insuranceForm.status.rawValue)
                            .foregroundColor(.yellow)
                    case FormStatus.approved:
                        Text(insuranceForm.status.rawValue)
                            .foregroundColor(.green)
                    case FormStatus.rejected:
                        Text(insuranceForm.status.rawValue)
                            .foregroundColor(.red)
                    default:
                        Text(insuranceForm.status.rawValue)
                            .foregroundColor(.primary)
                    }
                }
                HStack {
                    Text("评估状态:")
                    Spacer()
                    switch insuranceForm.assessmentStatus {
                    case AssessmentStatus.passed:
                        Text(insuranceForm.assessmentStatus.rawValue)
                            .foregroundColor(.green)
                    case AssessmentStatus.failed:
                        Text(insuranceForm.assessmentStatus.rawValue)
                            .foregroundColor(.red)
                    default:
                        Text(insuranceForm.assessmentStatus.rawValue)
                            .foregroundColor(.orange)
                    }
                }
                
                Divider()
                
                Form {
                    Section(header: Text("审核信息").font(.headline)) {
                        HStack {
                            Text("审批评论:")
                            TextEditor(text: $insuranceForm.comment)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.secondary, lineWidth: 1)
                                )
                        }
                    }
                }
                
            } else {
                // 客户更新基本信息表单
                Form {
                    Section(header: Text("基本信息").font(.headline)) {
                        HStack {
                            Text("投保人:")
                            Spacer()
                            TextField("policyholder", text: $insuranceForm.policyholder)
                        }
                        HStack {
                            Text("被保人:")
                            Spacer()
                            TextField("insured", text: $insuranceForm.insured)
                        }
                        HStack {
                            Text("投保金额:")
                            TextField("insured", value: $insuranceForm.premium, formatter: getDoubleFormatter())
                                .keyboardType(.decimalPad)
                        }
                        Slider(
                            value: $insuranceForm.premium,
                            in: ClosedRange(uncheckedBounds: (lower: insuranceProduct.premiumMin, upper: insuranceProduct.premiumMax))
                        ) {
                            Text("投保限额")
                        } minimumValueLabel: {
                            Text(insuranceProduct.premiumMin.description)
                        } maximumValueLabel: {
                            Text(insuranceProduct.premiumMax.description)
                        }
                    }
                }
            }
            
            Divider()

        }
//        .onAppear(perform: {
//            if insuranceProduct != nil {
//                
//            }
//        })
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    FormEdit(insuranceForm: .constant(InsuranceForm(productId: "0", userId: "0")))
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
