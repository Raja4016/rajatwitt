//
//  imagePickerCell.swift
//  Raja
//
//  Created by HTS-MAC on 16/06/22.
//

import UIKit

class imagePickerCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.cornerRadius = 20
    }
    
}
