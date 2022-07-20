//
//  userViewModel.swift
//  Raja
//
//  Created by HTS-MAC on 15/06/22.
//

import UIKit

class userViewModel{
    var userModel: UserModel?
    
    func getUsersFromLocal(onSuccess Result: @escaping (Bool) -> Void, onFailure failure: @escaping (Error) -> Void){
        
        let localObj = LocalStorage()
        let jsonResult = localObj.getAllUsers()
        if jsonResult["status_code"].intValue == 200{
            let rootClass = UserModel.init(fromJson: jsonResult)
            self.userModel = rootClass
            Result(true)
        } else{
            ApiServices().getDataCall(url: GET_USER_URL, onSuccess: {(success) in
                let rootClass = UserModel.init(fromJson: success)
                self.userModel = rootClass
                DispatchQueue.main.async {
                    for userModel in self.userModel!.usersDetail{
                        localObj.storeUserDetatils(userDetail: userModel)
                    }
                }
                Result(true)
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func getSpecificUsersFromLocal(userName: String,onSuccess Result: @escaping (Bool) -> Void, onFailure failure: @escaping (Error) -> Void){
        
        let localObj = LocalStorage()
        let jsonResult = localObj.getUser(userName: userName)
        if jsonResult["status_code"].intValue == 200{
            let rootClass = UserModel.init(fromJson: jsonResult)
            self.userModel = rootClass
            Result(true)
        } else{
            ApiServices().getDataCall(url: GET_USER_URL, onSuccess: {(success) in
                let rootClass = UserModel.init(fromJson: success)
                self.userModel = rootClass
                DispatchQueue.main.async {
                    for userModel in self.userModel!.usersDetail{
                        localObj.storeUserDetatils(userDetail: userModel)
                    }
                    self.getSpecificUsersFromLocal(userName: userName, onSuccess: { _ in
                        
                    }, onFailure: { _ in
                        
                    })
                }
            }, onFailure: { (error) in
                print(error.localizedDescription)
            })
        }
    }
}
