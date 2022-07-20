//
//  profilePageVC.swift
//  Raja
//
//  Created by HTS-MAC on 15/06/22.
//

import UIKit

class profilePageVC: UIViewController{
    
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var backBtnImageView: UIImageView!
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var profileDetatilView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var joinDateLbl: UILabel!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    
    @IBOutlet weak var uerimageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var pinTableView: UITableView!
    
    var viewModel = userViewModel()
    let localStorage = LocalStorage()
    var recent_ViewModel = recentViewModel()
    var userDetatilArray = [UsersDetailModel]()
    var pageFrom = ""
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigOutlet()
        ConfigTV()
        if pageFrom == "ownProfile"{
            configOwnProfileUI(detail: ownUserDetatil)
            getOwnuserPost()
        } else{
            getDataFromLocal()
        }
    }
    
    func ConfigOutlet(){
        self.uerimageView.RoundedCornerRadius()
        self.userImage.RoundedCornerRadius()
    }
    
    func ConfigTV(){
        self.pinTableView.delegate = self
        self.pinTableView.dataSource = self
        self.pinTableView.separatorStyle = .none
        self.pinTableView.register(UINib(nibName: "homePageCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    func getDataFromLocal(){
        self.viewModel.getSpecificUsersFromLocal(userName: self.userName, onSuccess: { (success) in
            if success{
                self.userDetatilArray = self.viewModel.userModel!.usersDetail
                self.configUI()
                self.getUsersPost()
            }
        }, onFailure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    func getUsersPost(){
        self.recent_ViewModel.getSpecifcPostFromLocal(user_name: self.userName, onSuccess: { (success) in
            if success{
                self.pinTableView.reloadData()
            }
        })
    }
    
    func getOwnuserPost(){
        self.recent_ViewModel.getOwnPostFromLocal(onSuccess: { (success) in
            if success{
                if self.recent_ViewModel.recentModel?.statusCode == 200{
                    self.pinTableView.reloadData()
                }
            }
        })
    }
    
    func configUI(){
        self.userImage.sd_setImage(with: URL(string: self.userDetatilArray[0].userImageURL), placeholderImage: #imageLiteral(resourceName: "user"))
        self.nameLbl.text = self.userDetatilArray[0].name
        self.userNameLbl.text = "@\(self.userDetatilArray[0].userName)"
        self.descLbl.text = self.userDetatilArray[0].bio
        self.linkLbl.text = self.userDetatilArray[0].link
        self.joinDateLbl.text = self.userDetatilArray[0].joinDate
        self.followingCountLbl.text = self.userDetatilArray[0].followingCount
        self.followersCountLbl.text = self.userDetatilArray[0].followersCount
    }
    
    func configOwnProfileUI(detail: NSDictionary){
        self.userImage.sd_setImage(with: URL(string: detail.value(forKey: "userImageUrl") as! String), placeholderImage: #imageLiteral(resourceName: "user"))
        self.nameLbl.text = detail.value(forKey: "name") as? String ?? ""
        self.userNameLbl.text = "@\(detail.value(forKey: "userName") as? String ?? "")"
        self.descLbl.text = detail.value(forKey: "bio") as? String ?? ""
        self.linkLbl.text = detail.value(forKey: "link") as? String ?? ""
        self.joinDateLbl.text = detail.value(forKey: "join_date") as? String ?? ""
        self.followingCountLbl.text = detail.value(forKey: "following_count") as? String ?? ""
        self.followersCountLbl.text = detail.value(forKey: "followers_count") as? String ?? ""
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func likeBtnTapped(_ sender:UIButton!) {
        let likeBtn: UIButton = sender
        let tag = likeBtn.tag
        let postId = self.recent_ViewModel.recentModel?.result[tag].postID
        let liked = self.recent_ViewModel.recentModel?.result[tag].liked
        if liked == "0" || liked == ""{
            self.recent_ViewModel.recentModel?.result[tag].liked = "1"
            if pageFrom == "ownProfile"{
                self.localStorage.updateOwnPostLike(post_id: postId!, liked: "1")
            } else{
                self.localStorage.updateLike(post_id: postId!, liked: "1")
            }
        } else{
            self.recent_ViewModel.recentModel?.result[tag].liked = "0"
            if pageFrom == "ownProfile"{
                self.localStorage.updateOwnPostLike(post_id: postId!, liked: "0")
            } else{
                self.localStorage.updateLike(post_id: postId!, liked: "0")
            }
        }
        self.pinTableView.reloadData()
        print("LIKE UPDATED")
    }
    
    @objc func shareBtnTapped(_ sender:UIButton!) {
        let tag = sender.tag
        let postId = self.recent_ViewModel.recentModel?.result[tag].postID
        let reShared = self.recent_ViewModel.recentModel?.result[tag].reshared
        
        if reShared == "0" || reShared == ""{
            self.recent_ViewModel.recentModel?.result[tag].reshared = "1"
            if pageFrom == "ownProfile"{
                self.localStorage.updateOwnPostShare(post_id: postId!, shared: "1")
            } else{
                self.localStorage.updateShare(post_id: postId!, shared: "1")
            }
        } else{
            self.recent_ViewModel.recentModel?.result[tag].reshared = "0"
            if pageFrom == "ownProfile"{
                self.localStorage.updateOwnPostShare(post_id: postId!, shared: "0")
            } else{
                self.localStorage.updateShare(post_id: postId!, shared: "0")
            }
        }
        self.pinTableView.reloadData()
        print("ReShared UPDATED")
    }
}

//MARK: - TableView DataSource ,Delegate
extension profilePageVC :  UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.recent_ViewModel.recentModel?.result.count) ?? 0 == 0{
            self.pinTableView.isHidden = true
        } else{
            self.pinTableView.isHidden = false
        }
        return (self.recent_ViewModel.recentModel?.result.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! homePageCell
        if pageFrom == "ownProfile"{
            if indexPath.row == 0{
                cell.configCell(data: (self.recent_ViewModel.recentModel?.result[indexPath.row])!, viewType: "pin")
            } else{
                cell.configCell(data: (self.recent_ViewModel.recentModel?.result[indexPath.row])!, viewType: "hideSuggest")
            }
        } else{
            cell.configCell(data: (self.recent_ViewModel.recentModel?.result[indexPath.row])!, viewType: "pin")
        }
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnTapped(_:)), for: .touchUpInside)
        
        cell.shareBtn.tag = indexPath.row
        cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
}
