//
//  userModel.swift
//  Raja
//
//  Created by HTS-MAC on 15/06/22.
//

import Foundation
import SwiftyJSON

// MARK: - UserModel
class UserModel: Codable {
    let statusCode: Int
    var usersDetail: [UsersDetailModel]
    
    init(fromJson json:JSON){
        self.statusCode = json["status_code"].intValue
        self.usersDetail = [UsersDetailModel]()
        let userDetatil = json["users_detail"].arrayValue
        for arrayValue in userDetatil{
            let value = UsersDetailModel.init(fromJson: arrayValue)
            usersDetail.append(value)
        }
    }
}

// MARK: - UsersDetail
class UsersDetailModel: Codable {
    let userName, name: String
    let userImageURL: String
    let bio, link, joinDate, followingCount: String
    let followersCount: String
    var following: String
    
    init(fromJson json:JSON){
        self.userName = json["user_name"].stringValue
        self.name = json["name"].stringValue
        self.userImageURL = json["user_image_url"].stringValue
        self.bio = json["bio"].stringValue
        self.link = json["link"].stringValue
        self.joinDate = json["join_date"].stringValue
        self.followingCount = json["following_count"].stringValue
        self.followersCount = json["followers_count"].stringValue
        self.following = json["following"].stringValue
    }
}

