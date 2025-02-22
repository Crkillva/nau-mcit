//
//  cit693Tests.swift
//  cit693Tests
//
//  Created by crkillva on 2025-02-11.
//

import Testing
import Foundation
@testable import cit693

struct cit693Tests {

    @Test func testHasher() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let plain_text = "123456"
        let hashed_text = try PasswordHasher.hash(plain_text)

        print("plain data: \(plain_text)")
        print("hased data: \(hashed_text)")
        #expect(try PasswordHasher.verify(plain_text, target: hashed_text))

    }
    
    @Test func testEnumFromRawValue() async throws {
        #expect(InsuranceType.SuperType.fromRawValue("") == InsuranceType.SuperType.others)
        #expect(InsuranceType.SuperType.fromRawValue("意外保险") == InsuranceType.SuperType.accident)
    }
    
    @Test func testRegisterUser() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let userRequestDTO = UserRequestDTO(username: "testuser", password: try PasswordHasher.hash("123456"), email: "testuser@test.com", role: UserRole.customer, rememberMe: true, isSignIn: false)
        let userId = try await UserService.registerUser(userRequestDTO: userRequestDTO)
        let user = try await UserService.fetchUserById(userId: userId)
        #expect(user.username == userRequestDTO.username)
    }
    
    @Test func testMatchUserForSignUp() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let result = try await UserService.matchUserForSignUp(username: "agent", email: "agent@test.com")

        #expect(result)
    }
    
    @Test func testMatchUserForSignIn() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let user: User? = try await UserService.matchUserForSignIn(username: "agent")
        
        print("User: \(String(describing: user))")
        #expect(user != nil)
    }
    
    @Test func testCreateForm() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let insuranceFormRequestDTO = InsuranceFormRequestDTO(productId: "1", userId: "1", policyholder: "String", insured: "String", premium: 0, assessmentStatus: String(describing: AssessmentStatus.pending), status: String(describing: FormStatus.drafted), date: formateDateString(Date()), reviewDate: formateDateString(Date()), reviewerId: "", comment: "")
        let formId = try await FormService.createForm(insuranceFormRequestDTO: insuranceFormRequestDTO)
        let form = try await FormService.fetchFormById(formId: formId)
        #expect(form.productId == insuranceFormRequestDTO.productId)
    }
    
    @Test func testUpdateForm() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//        let formDict_save = ["Id": 1, "policyholder": "aaa", "insured": "bbb", "premium": 100] as [String : Any]
//        let formDict_submit = ["Id": 1, "status": String(describing: FormStatus.submitted), "date": formateDateString(Date())] as [String : Any]
//        let formDict_assess = ["Id": 1, "assessmentStatus": String(describing: AssessmentStatus.passed), "comment": "ok"] as [String : Any]
        let formDict_review = ["Id": 1, "status": String(describing: FormStatus.approved), "reviewDate": formateDateString(Date()), "reviewerId": "1", "comment": "approved"] as [String : Any]
        
        try await FormService.updateForm(formDict_review)
        #expect(true)
    }
    
    @Test func testStringToEnumCase() async throws {
        let dict: [String: Any] = ["assessmentStatus": "passed"]
        let result = AssessmentStatus.fromRawValue(dict["assessmentStatus"] as? String ?? "")
        print(String(describing: result))
        #expect(result == AssessmentStatus.passed)
    }
    
    @Test func testFetchForms() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let forms: [InsuranceForm] = try await FormService.fetchForms()
        print("forms size: \(forms.count)")
        #expect(!forms.isEmpty)
    }
    
    @Test func testFetchForm() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let form: InsuranceForm = try await FormService.fetchFormById(formId: 8)
        #expect(form.id == "8")
    }

    @Test func testFormVM() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let formVM = await FormVM()
        let ret: Bool = try await formVM.createForm(productId: "1", user: User(userDTO: UserDTO(username: "test", password: PasswordHasher.hash("123456"), email: "test@test.com", role: UserRole.customer, rememberMe: true, isSignIn: false)))
        #expect(ret)
    }
    
    @Test func testFetchProducts() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let products: [InsuranceProduct] = try await ProductService.fetchProducts()
        print("list size = \(products.count)")
        products.forEach { item in
            print("id: \(item.id), name: \(item.name), \(item.type), \(item.subType)")
        }
        #expect(!products.isEmpty)
    }
    
    @Test func testFetchProductById() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let product: InsuranceProduct = try await ProductService.fetchProductById(productId: "4")
        #expect(product.id == "4")
    }
    

}
