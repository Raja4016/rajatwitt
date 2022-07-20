//
//  homePageVC.swift
//  Raja
//
//  Created by HTS-MAC on 11/06/22.
//

import UIKit
import SDWebImage
import Toast_Swift

class homePageVC: UIViewController{
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardBtn: UIButton!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var viewModel = recentViewModel()
    let localStorage = LocalStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalSetup()
        self.ConfigTV()
    }
    
    func initalSetup(){
        self.profileImg.sd_setImage(with: URL(string: ownUserDetatil.value(forKey: "userImageUrl") as? String ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
        self.profileImg.RoundedCornerRadius()
        self.cardView.RoundedCornerRadius()
        self.navigationView.backgroundColor = .white
        self.loader.color = .blue
        self.loader.hidesWhenStopped = true
        self.loader.startAnimating()
    }
    
    func ConfigTV(){
        self.homeTableView.register(UINib(nibName: "homePageCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.homeTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.getRecentFromLocal(onSuccess: { (success)in
            if success == true{
                self.loader.stopAnimating()
                self.homeTableView.reloadData()
            }
        }, onFailure: { (error)in
            self.loader.stopAnimating()
            print(error.localizedDescription)
        })
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        
        let profileObj = profilePageVC()
        profileObj.pageFrom = "ownProfile"
        profileObj.modalPresentationStyle = .fullScreen
        self.present(profileObj, animated: true, completion: nil)
    }
    
    @IBAction func cardBtnTapped(_ sender: Any) {
        let composeObj = composeVC()
        composeObj.Success = {
            self.view.makeToast("Posted Successfully")
        }
        composeObj.modalPresentationStyle = .fullScreen
        self.present(composeObj, animated: true, completion: nil)
    }
    
    @objc func UserprofileBtnTapped(_ sender:UIButton!) {
        let tag = sender.tag
        let userName = self.viewModel.recentModel?.result[tag].postedBy.userName
        let profileObj = profilePageVC()
        profileObj.userName = userName ?? ""
        profileObj.modalPresentationStyle = .fullScreen
        self.present(profileObj, animated: true, completion: nil)
    }
    
    @objc func likeBtnTapped(_ sender:UIButton!) {
        let likeBtn: UIButton = sender
        let tag = likeBtn.tag
        let postId = self.viewModel.recentModel?.result[tag].postID
        let liked = self.viewModel.recentModel?.result[tag].liked
        if liked == "0" || liked == ""{
            self.viewModel.recentModel?.result[tag].liked = "1"
            self.localStorage.updateLike(post_id: postId!, liked: "1")
        } else{
            self.viewModel.recentModel?.result[tag].liked = "0"
            self.localStorage.updateLike(post_id: postId!, liked: "0")
        }
        self.homeTableView.reloadData()
    }
    
    @objc func shareBtnTapped(_ sender:UIButton!) {
        let tag = sender.tag
        let postId = self.viewModel.recentModel?.result[tag].postID
        let reShared = self.viewModel.recentModel?.result[tag].reshared
        
        if reShared == "0" || reShared == ""{
            self.viewModel.recentModel?.result[tag].reshared = "1"
            self.localStorage.updateShare(post_id: postId!, shared: "1")
        } else{
            self.viewModel.recentModel?.result[tag].reshared = "0"
            self.localStorage.updateShare(post_id: postId!, shared: "0")
        }
        self.homeTableView.reloadData()
    }
    
}

//MARK: - TableView Delegate and datasource
extension homePageVC:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel.recentModel?.result.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! homePageCell
        cell.configCell(data: (self.viewModel.recentModel?.result[indexPath.row])!, viewType: "")
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnTapped(_:)), for: .touchUpInside)
        
        cell.shareBtn.tag = indexPath.row
        cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
        
        cell.profileBtn.addTarget(self, action: #selector(UserprofileBtnTapped(_:)), for: .touchUpInside)
        cell.profileBtn.tag = indexPath.row
        return cell
    }
}

