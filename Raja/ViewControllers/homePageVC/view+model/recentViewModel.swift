//
//  recentViewModel.swift
//  Raja
//
//  Created by HTS-MAC on 14/06/22.
//

import UIKit
import Alamofire

class recentViewModel {
    var recentModel: RecentModel?
    
    func getRecentFromApi(onSuccess Result: @escaping (Bool) -> Void, onFailure failure: @escaping (Error) -> Void){
        
        let _: [String: Any] = ["api_username":"joySale", "api_password":"0RWK9XM8"]
        
        ApiServices().getDataCall(url: "https://appservices.hitasoft.in/freepost/api/postdetails", onSuccess: {(success) in
            Result(true)
            let rootClass = RecentModel.init(fromJson: success)
            self.recentModel = rootClass
            
        }, onFailure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    func getRecentFromLocal(onSuccess Result: @escaping (Bool) -> Void, onFailure failure: @escaping (Error) -> Void){
        let localObj = LocalStorage()
        
        let jsonResult = localObj.getAllPosters()
        if jsonResult["status_code"].intValue == 200{
            let rootClass = RecentModel.init(fromJson: jsonResult)
            self.recentModel = rootClass
            Result(true)
        } else{
            ApiServices().getDataCall(url: POST_URL, onSuccess: {(success) in
                let rootClass = RecentModel.init(fromJson: success)
                self.recentModel = rootClass
                DispatchQueue.main.async {
                    for postModel in self.recentModel!.result{
                        localObj.savePost(recent: postModel)
                    }
                }
                Result(true)
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func getSpecifcPostFromLocal(user_name: String, onSuccess Result: @escaping (Bool) -> Void){
        let localObj = LocalStorage()
        let jsonResult = localObj.getSpeficPost(username: user_name)
        if jsonResult["status_code"].intValue == 200{
            let rootClass = RecentModel.init(fromJson: jsonResult)
            self.recentModel = rootClass
            Result(true)
        }
    }
    
    
    func getOwnPostFromLocal(onSuccess Result: @escaping (Bool) -> Void){
        let localObj = LocalStorage()
        let jsonResult = localObj.getAllOwnPost()
        if jsonResult["status_code"].intValue == 200{
            let rootClass = RecentModel.init(fromJson: jsonResult)
            self.recentModel = rootClass
            Result(true)
        }
    }
    
}
