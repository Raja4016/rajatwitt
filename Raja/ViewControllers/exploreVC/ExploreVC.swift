//
//  ExploreVC.swift
//  Raja
//
//  Created by HTS-MAC on 11/06/22.
//

import UIKit

class ExploreVC: UIViewController {
    
    @IBOutlet weak var noTrendsView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var noSearchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var uesrBtn: UIButton!
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTableViewBottomConstraint: NSLayoutConstraint!
    
    let localStorage = LocalStorage()
    var viewModel = userViewModel()
    var userDetatilArray = [UsersDetailModel]()
    var ConstantUserDetatilArray = [UsersDetailModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalSetup()
        ConfigTV()
        getUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        self.searchTableViewBottomConstraint.constant = 0
//        [self.noSearchView, self.noTrendsView].forEach { view in
//            view?.isHidden = false
//        }
    }
    
    func initalSetup(){
        self.userImageView.sd_setImage(with: URL(string: ownUserDetatil.value(forKey: "userImageUrl") as? String ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
        [self.statusView, self.userImageView].forEach { view in
            view?.RoundedCornerRadius()
        }
        [self.noSearchView, self.searchView].forEach { view in
            view?.cornerRadius = 20
            view?.backgroundColor = .secondarySystemBackground
        }
        
        self.searchField.delegate = self
        self.searchField.layer.borderWidth = 0.0
        self.searchField.layer.borderColor = UIColor.clear.cgColor
        self.searchField.backgroundColor = .clear
    }
    
    //MARK: Config TV
    func ConfigTV(){
        self.searchTableView.register(UINib(nibName: "exploreCellCell", bundle: nil), forCellReuseIdentifier: "cell1")
        self.searchTableView.isHidden = true
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.searchTableView.separatorStyle = .none
    }
    
    func getUserData(){
        self.viewModel.getUsersFromLocal(onSuccess: { (success) in
            if success{
                self.userDetatilArray = self.viewModel.userModel!.usersDetail
                self.ConstantUserDetatilArray = self.viewModel.userModel!.usersDetail
            }
        }, onFailure: { (error) in
            print(error.localizedDescription)
        })
    }
    
    @objc func followBtnTapped(_ sender:UIButton!) {
        let tag = sender.tag
        if self.userDetatilArray[tag].following == "0" || self.userDetatilArray[tag].following == ""{
            self.userDetatilArray[tag].following = "1"
            self.localStorage.updateFollwing(userName: self.userDetatilArray[tag].name, following: "1")
            
        } else{
            self.userDetatilArray[tag].following = "0"
            self.localStorage.updateFollwing(userName: self.userDetatilArray[tag].name, following: "0")
        }
        self.searchTableView.reloadData()
        
    }
    
    @objc func profileBtnTapped(_ sender:UIButton!) {
        let tag = sender.tag
        let username = self.userDetatilArray[tag].userName
        let vc = profilePageVC()
        vc.userName = username
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func userBtntapped(_ sender: Any) {
        print("profileBtnTapped")
        let vc = profilePageVC()
        vc.pageFrom = "ownProfile"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func searchFieldDidBegin(_ sender: Any) {
        self.noSearchView.isHidden = true
        self.noTrendsView.isHidden = true
        self.searchTableView.isHidden = false
        self.searchTableView.reloadData()
    }
    
    @IBAction func searchFieldEditingChanged(_ sender: Any) {
        let fieldText = self.searchField.text
        let textCount = fieldText?.count
        self.userDetatilArray.removeAll()
        if searchField.text == ""{
            self.userDetatilArray = ConstantUserDetatilArray
        } else{
            self.userDetatilArray = self.ConstantUserDetatilArray.filter  {
                ($0.name.lowercased().contains(self.searchField.text ?? "".lowercased())) || ($0.userName.lowercased().contains(self.searchField.text ?? "".lowercased()))
    //            return ($0.name.contains(where: self.searchField.text ?? "")!)
    //            print($0.name)
    //            return true
            }
        }
        
//        for i in self.ConstantUserDetatilArray{
//            if fieldText?.lowercased() == String(i.name.prefix(textCount!)).lowercased() || fieldText?.lowercased() == String(i.userName.prefix(textCount!)).lowercased(){
//                self.userDetatilArray.append(i)
//            }
//        }
        self.searchTableView.reloadData()
    }
    
}

//MARK: - TV delegate and data source
extension ExploreVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userDetatilArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! exploreCellCell
        cell.selectionStyle = .none
        cell.userImageView.sd_setImage(with: URL(string: userDetatilArray[indexPath.row].userImageURL), placeholderImage: #imageLiteral(resourceName: "user"))
        cell.userNameLbl.text = "@\(userDetatilArray[indexPath.row].userName)"
        cell.nameLbl.text = userDetatilArray[indexPath.row].name
        cell.followBtn.tag = indexPath.row
        cell.followBtn.addTarget(self, action: #selector(followBtnTapped(_:)), for: .touchUpInside)
        cell.profileBtn.tag = indexPath.row
        cell.profileBtn.addTarget(self, action: #selector(profileBtnTapped(_:)), for: .touchUpInside)
        if userDetatilArray[indexPath.row].following == "0"{
            cell.followBtn.setTitle("Follow", for: .normal)
            cell.followBtn.setTitleColor(.blue, for: .normal)
        } else{
            cell.followBtn.setTitle("Following", for: .normal)
            cell.followBtn.setTitleColor(.green, for: .normal)
        }
        return cell
    }
}

//MARK: - UITextFieldDelegate
extension ExploreVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTableViewBottomConstraint.constant = 0
        self.searchField.resignFirstResponder()
        return true
    }
    
    @objc func keyBoardDidShow(_ notification:Notification) {
        self.searchTableViewBottomConstraint.constant = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height - 20
    }
}
