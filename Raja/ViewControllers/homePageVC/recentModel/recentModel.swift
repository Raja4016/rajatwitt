//
//  recentModel.swift
//  Raja
//
//  Created by HTS-MAC on 14/06/22.
//

import Foundation
import SwiftyJSON

import Foundation

// MARK: - RecentModel
class RecentModel: Codable {
    let statusCode: Int
    var result: [PostsModel]
    
    init(fromJson json: JSON){
        statusCode = json["status_code"].intValue
        result = [PostsModel]()
        let resultArray = json["result"].arrayValue
        for arrayValue in resultArray{
            let value = PostsModel.init(formJson: arrayValue)
            result.append(value)
        }
    }
    
}

// MARK: - Result
class PostsModel: Codable {
    var postID: String
    var reshared: String
    var postedBy: PostedBy
    let postedTime, suggestedType: String
    var suggestedBy: String
    var likeCount, resharedCount, liked: String
    let postType, composedDetail, composedImageURL: String
    
    
    init(formJson json:JSON){
        self.postID = json["post_id"].stringValue
        self.postedTime = json["posted_time"].stringValue
        self.suggestedType = json["suggested_type"].stringValue
        self.suggestedBy = json["suggested_by"].stringValue
        self.likeCount = json["like_count"].stringValue
        self.resharedCount = json["reshared_count"].stringValue
        self.liked = json["liked"].stringValue
        self.reshared = json["reshared"].stringValue
        self.postType = json["post_type"].stringValue
        self.composedDetail = json["composed_detail"].stringValue
        self.composedImageURL = json["composed_image_url"].stringValue
        
        let postByValue = json["posted_by"]
        self.postedBy = PostedBy.init(fromJson: postByValue)
    }
}

// MARK: - PostedBy
class PostedBy: Codable {
    let userName, name: String
    let userImageURL: String
    
    init(fromJson json:JSON){
        self.userName = json["user_name"].stringValue
        self.name = json["name"].stringValue
        self.userImageURL = json["user_image_url"].stringValue
    }
}
