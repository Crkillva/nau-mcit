//
//  FormVM.swift
//  cit693
//
//  Created by crkillva on 2025-02-19.
//
// viewmodel 用于处理保单各种操作场景

import Foundation

@MainActor
class FormVM: ObservableObject {
    @Published var insuranceForms: [InsuranceForm] = []
    @Published var insuranceForm: InsuranceForm = InsuranceForm(productId: "0", userId: "0")
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // 将推荐方案生成保单
    func createForm(productId: String, user: User?) async -> Bool {
        guard let user = user else {
            showError = true
            errorMessage = AuthError.unknowUserOperation.localizedDescription
            return false
        }
        do {
            let insuranceProduct: InsuranceProduct = try await ProductService.fetchProductById(productId: productId)
            let insuranceFormRequestDTO = InsuranceFormRequestDTO(productId: insuranceProduct.id, userId: user.id, policyholder: user.username, insured: user.username, premium: insuranceProduct.premiumMin, assessmentStatus: String(describing: AssessmentStatus.pending), status: String(describing: FormStatus.drafted), date: formateDateString(Date()), reviewDate: formateDateString(Date()), reviewerId: "", comment: "")
            let formId = try await FormService.createForm(insuranceFormRequestDTO: insuranceFormRequestDTO)
            insuranceForm = try await FormService.fetchFormById(formId: formId)
            return true
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            print("failed to create Insurance Form. \(errorMessage)")
            return false
        }
    }
    
    // 更新保单通用函数
    func updateForm(_ formDict: [String : Any]) async {
        do {
            try await FormService.updateForm(formDict)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    // 客户保存保单信息
    func saveForm(_ form: InsuranceForm) async {
        let formDict = ["Id": StringToInt(form.id), "policyholder": form.policyholder, "insured": form.insured, "premium": form.premium] as [String : Any]
        await updateForm(formDict)
    }
    
    // 客户提交保单
    func submitForm(_ form: InsuranceForm) async {
        let formDict = ["Id": StringToInt(form.id), "status": String(describing: FormStatus.submitted), "date": formateDateString(Date())] as [String : Any]
        await updateForm(formDict)
    }
    
    // 投保代理员或只能顾问评估保单
    func assessForm(_ form: InsuranceForm) async {
        let formDict = ["Id": StringToInt(form.id), "assessmentStatus": String(describing: AssessmentStatus.passed)] as [String : Any]
        await updateForm(formDict)
    }
    
    // 投保代理员批准保单
    func approveForm(_ form: InsuranceForm, userId: String) async {
        let formDict = ["Id": StringToInt(form.id), "status": String(describing: FormStatus.approved), "reviewDate": formateDateString(Date()), "reviewerId": userId, "comment": form.comment] as [String : Any]
        await updateForm(formDict)
    }
    
    // 投保代理员拒绝保单
    func rejectForm(_ form: InsuranceForm, userId: String) async {
        let formDict = ["Id": StringToInt(form.id), "status": String(describing: FormStatus.rejected), "reviewDate": formateDateString(Date()), "reviewerId": userId, "comment": form.comment] as [String : Any]
        await updateForm(formDict)
    }
    
    // 获取保单列表
    func loadForms() async throws {
        insuranceForms = try await FormService.fetchForms()
    }
    
}
