//
//  FormDetail.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 保单详细信息视图，只读。

import SwiftUI

struct FormDetail: View {
    @State var insuranceForm: InsuranceForm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            Text("保单详情")
                .font(.title)
            Divider()
            
            HStack {
                Text("编号:")
                Spacer()
                Text(insuranceForm.id)
            }
                
            Text("基本信息")
                .font(.headline)
            
            HStack {
                Text("投保人:")
                Spacer()
                Text(insuranceForm.policyholder)
            }
            HStack {
                Text("被保人:")
                Spacer()
                Text(insuranceForm.insured)
            }
            HStack {
                Text("投保金额:")
                Spacer()
                Text(getDoubleFormatter().string(from: insuranceForm.premium as NSNumber) ?? "0.00")
            }
            
            HStack {
                Text("保单日期:")
                Spacer()
                Text(formateDateString(insuranceForm.date))
            }
            
            Divider()
            
            Text("审核信息")
                .font(.headline)
            
            HStack {
                Text("处理状态:")
                Spacer()
                switch insuranceForm.status {
                case FormStatus.submitted:
                    Text(insuranceForm.status.rawValue)
                        .foregroundColor(.orange)
                case FormStatus.approved:
                    Text(insuranceForm.status.rawValue)
                        .foregroundColor(.green)
                case FormStatus.rejected:
                    Text(insuranceForm.status.rawValue)
                        .foregroundColor(.red)
                default:
                    Text(insuranceForm.status.rawValue)
                        .foregroundColor(.gray)
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
            if [FormStatus.approved, FormStatus.rejected].contains(insuranceForm.status) {
                HStack {
                    Text("审批人编号:")
                    Spacer()
                    Text(insuranceForm.reviewerId)
                }
                HStack {
                    Text("审批评论:")
                    Spacer()
                    Text(insuranceForm.comment)
                }
                HStack {
                    Text("审批日期:")
                    Spacer()
                    Text(formateDateString(insuranceForm.reviewDate))
                }
            }
            
            Divider()
                
        }
    }
}


#Preview {
    FormDetail(insuranceForm: InsuranceForm(productId: "0", userId: "0"))
}
