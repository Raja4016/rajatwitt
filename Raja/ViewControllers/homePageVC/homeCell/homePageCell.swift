//
//  homePageCell.swift
//  Raja
//
//  Created by HTS-MAC on 11/06/22.
//

import UIKit
import ActiveLabel
import SDWebImage

class homePageCell: UITableViewCell {
    
    @IBOutlet weak var suggstionView: UIView!
    @IBOutlet weak var suggestionImageView: UIImageView!
    @IBOutlet weak var suggestionLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descLbl: ActiveLabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var shareCountLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var composeImage: UIImageView!
    @IBOutlet weak var composeImageView: UIView!
    @IBOutlet weak var profileBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.frame = self.bounds
        self.descLbl.numberOfLines = 6
        self.descLbl.enabledTypes = [.mention, .hashtag, .url]
        self.userImageView.cornerRadius = 20
        self.composeImage.cornerRadius = 40
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(data: PostsModel, viewType: String){
        if data.postType == "image"{
            self.composeImage.isHidden = false
            self.composeImageView.isHidden = false
            do {
                let imageData: NSData = try! NSData(contentsOf: Uitility.shared.filePath(forKey: data.composedImageURL)!)
                self.composeImage.image = UIImage(data: imageData as Data)
            } catch {
                print("Error loading image : \(error.localizedDescription)")
            }
        } else{
            self.composeImage.isHidden = true
            self.composeImageView.isHidden = true
        }
        
        if viewType == "pin"{
            self.suggestionImageView.image = #imageLiteral(resourceName: "pin")
            self.suggestionLbl.text = "Pinned"
        } else if viewType == "hideSuggest"{
            self.suggstionView.isHidden = true
        } else{
            if data.suggestedType == "liked"{
                self.suggestionImageView.image = #imageLiteral(resourceName: "sLike")
                self.suggestionLbl.text = "\(data.suggestedBy) liked"
            } else if data.suggestedType == "Reshared"{
                self.suggestionImageView.image = #imageLiteral(resourceName: "retweet")
                self.suggestionLbl.text = "\(data.suggestedBy) Reshared"
            }
        }
        
        self.nameLbl.text = data.postedBy.name
        self.userNameLbl.text = "@\(data.postedBy.userName)"
        self.userImageView.sd_setImage(with: URL(string: data.postedBy.userImageURL), placeholderImage: #imageLiteral(resourceName: "user"))
        self.descLbl.text = data.composedDetail
        
        DispatchQueue.main.async {
            if data.reshared == "0" || data.reshared == ""{
                self.shareImageView.image = #imageLiteral(resourceName: "retweet")
                self.shareCountLbl.text = data.resharedCount
            } else{
                self.shareImageView.image = #imageLiteral(resourceName: "retweeted")
                var actualCount = Int(data.resharedCount) ?? 0
                actualCount += 1
                self.shareCountLbl.text = "\(actualCount)"
            }
            if data.liked == "0" || data.liked == ""{
                self.likeImageView.image = #imageLiteral(resourceName: "unlike")
                self.likeCountLbl.text = data.likeCount
                self.likeCountLbl.textColor = .systemGray2
            } else{
                self.likeImageView.image = #imageLiteral(resourceName: "like")
                var actualCount = Int(data.likeCount) ?? 0
                actualCount += 1
                self.likeCountLbl.text = "\(actualCount)"
                self.likeCountLbl.textColor = .red
            }
        }
    }
}
