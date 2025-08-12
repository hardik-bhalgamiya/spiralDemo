//
//  AppCenterModels.swift
//  VPracticalTask
//
//  Created by Hardik Bhalgamiya on 13/08/25.
//

import Foundation

//Response 
struct AppCenterResponse : Decodable {
    let status: Int
    let message: String
    let app_center : [app_center]
    
}

// MARK: - AppCenter
struct app_center : Decodable {
    let sub_category: [sub_category]
}

// MARK: - SubCategory
struct sub_category : Decodable {
    let name: String
    let icon: String
    let star, installed_range, app_link, banner: String
    let bannerImage: String?
}

