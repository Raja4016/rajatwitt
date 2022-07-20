//
//  Uitility.swift
//  Raja
//
//  Created by  on 17/06/22.
//

import Foundation
import UIKit

class Uitility{
    static let shared = Uitility()
    
    func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".jpg")
    }
    
    func store(image: Data, forKey key: String) {
        if let filePath = filePath(forKey: key) {
            do  {
                try image.write(to: filePath, options: .atomic)
            } catch let err {
                print("Saving file resulted in error: ", err)
            }
        }
    }
}
