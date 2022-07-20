//
//  ApiServices.swift
//  Raja
//
//  Created by HTS-MAC on 14/06/22.
//

import UIKit
import Alamofire
import SwiftyJSON

public typealias Parameters = [String: Any]

class ApiServices: NSObject {
    
    func getDataCall(url: String, onSuccess success: @escaping(JSON) -> Void, onFailure failure: @escaping(Error) -> Void){
        
        let url = URL(string: url)
        AF.request(url!, method: .get).responseJSON(completionHandler: { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                success(json)
            case .failure(let error):
                print("failureresponse: \(error) API: \(String(describing: url))")
                failure(error)
            }
            
        })
    }
    
}
