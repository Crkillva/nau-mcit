//
//  Error.swift
//  cit693
//
//  Created by crkillva on 2025-02-17.
//
// 定义错误类型 用于异常处理

import Foundation

enum HttpError: Error {
    case cannotConstructHttpBody
    case cannotDecodeJsonResponse
    case registerUserFailed
    case createRecordFailed
    case fetchRecordFailed
}

enum AuthError: Error {
    case userExists
    case invalidCredentials
    case unauthorized
    case abnormalUserStatus
    case encodingError
    case unknowUserOperation
}
