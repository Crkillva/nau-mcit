//
//  FormHost.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// 保单查看/编辑视图，根据编辑模式决定子视图，并根据用户权限控制工具栏的按钮。

import SwiftUI

struct FormHost: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject var consultancyOptions: ConsultancyOptions
    @EnvironmentObject var formVM: FormVM
    @Binding var insuranceForm: InsuranceForm
    @State private var hostMode: HostMode = HostMode.view
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                // 根据操作模式选择显示对应的视图
                switch hostMode {
                case HostMode.edit:
                    FormEdit(insuranceForm: $insuranceForm)
                case HostMode.view:
                    FormDetail(insuranceForm: insuranceForm)
                default:
                    Text("保单操作异常")
                        .foregroundColor(.red)
                }
                    // 显示关联的保险产品信息
                ScrollView {
                    ProductInfo(item: consultancyOptions.getProductById(id: insuranceForm.productId) ?? InsuranceProduct())
                }
            }
            
//            .padding()
        }
        .alert("🚨错误", isPresented: $formVM.showError) {
        } message: {
            Text(formVM.errorMessage)
        }
        .toolbar {
            // 在导航栏右侧添加按钮，以及权限控制按钮显示
            if auth.currentUser?.role == UserRole.agent {
                // 保单提交后，投保代理员可进行的操作
                if insuranceForm.status == FormStatus.submitted {
                    if hostMode == HostMode.edit {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                guard let user = auth.currentUser else {
                                    auth.showError = true
                                    auth.errorMessage = "用户会话已失效，请重新登录"
                                    return
                                }
                                Task {
                                    await formVM.approveForm(insuranceForm, userId: user.id)
                                }
                                insuranceForm.status = FormStatus.approved
                                hostMode = HostMode.view
                            } label: {
                                Text("\(Image(systemName: "checkmark.circle"))批准")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                guard let user = auth.currentUser else {
                                    auth.showError = true
                                    auth.errorMessage = "用户会话已失效，请重新登录"
                                    return
                                }
                                Task {
                                    await formVM.rejectForm(insuranceForm, userId: user.id)
                                }
                                insuranceForm.status = FormStatus.rejected
                                hostMode = HostMode.view
                            } label: {
                                Text("\(Image(systemName: "xmark.circle"))拒绝")
                            }
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                Task {
                                    await formVM.assessForm(insuranceForm)
                                }
                                insuranceForm.assessmentStatus = AssessmentStatus.passed
                            } label: {
                                Text("\(Image(systemName: "checklist"))评估")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                hostMode = HostMode.edit
                            } label: {
                                Text("\(Image(systemName: "square.and.pencil"))审批")
                            }
                        }
                    }
                }
            } else {
                // 客户在草稿状态时可进行的操作
                if insuranceForm.status == FormStatus.drafted {
                    if hostMode == HostMode.edit {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                Task {
                                    await formVM.saveForm(insuranceForm)
                                }
                                hostMode = HostMode.view
                            } label: {
                                Text("\(Image(systemName: "square.and.arrow.down"))完成")
                            }
                        }
                    } else {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                Task {
                                    await formVM.submitForm(insuranceForm)
                                }
                                insuranceForm.status = FormStatus.submitted
                                auth.tabSelection = Tab.formList
                            } label: {
                                Text("\(Image(systemName: "square.and.arrow.up"))提交保单")
                            }
                            Button {
                                hostMode = HostMode.edit
                            } label: {
                                Text("\(Image(systemName: "square.and.pencil"))编辑")

                            }
                        }
                    }
                }
                    
            }
        }
        .padding()
    }
}
    

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    FormHost(insuranceForm: .constant(InsuranceForm(productId: "0", userId: "0")))
        .environmentObject(AuthViewModel().setupModelContext(modelContext: modelContext))
        .environmentObject(ConsultancyOptions())
        .environmentObject(FormVM())
}
