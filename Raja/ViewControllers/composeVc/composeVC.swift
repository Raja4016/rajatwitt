//
//  composeVC.swift
//  Raja
//
//  Created by HTS-MAC on 15/06/22.
//

import UIKit
import Photos
import SwiftyJSON

class composeVC: UIViewController{
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var imageCloseBtn: UIButton!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    var Success: (() -> Void)?
    var assets: PHFetchResult<AnyObject>?
    
    let localStorage = LocalStorage()
    var model: PostsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalSetup()
        self.checkAccess()
        self.ConfigCV()
        self.ConfigTxtV()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func initalSetup(){
        self.imageCloseBtn.isHidden = true
        self.loader.color = .blue
        self.loader.hidesWhenStopped = true
        self.cancelBtn.setTitle("Cancel", for: .normal)
        self.cancelBtn.setTitleColor(.blue, for: .normal)
        self.postBtn.setTitle("Post", for: .normal)
        self.postBtn.setTitleColor(.white, for: .normal)
        self.postBtn.backgroundColor = .blue.withAlphaComponent(0.5)
        self.postBtn.isUserInteractionEnabled = false
        self.postBtn.RoundedCornerRadius()
        self.userImageView.RoundedCornerRadius()
        self.selectedImageView.cornerRadius = 20
        
        self.userImageView.sd_setImage(with: URL(string: ownUserDetatil.value(forKey: "userImageUrl") as! String), placeholderImage: #imageLiteral(resourceName: "user"))
    }
    
    
    func ConfigCV(){
        self.imageCollectionView.register(UINib(nibName: "imagePickerCell", bundle: nil), forCellWithReuseIdentifier: "imagePickerCell")
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.showsHorizontalScrollIndicator = false
    }
    
    
    func ConfigTxtV(){
        self.textView.delegate = self
        self.textView.isEditable = true
        self.textView.text = "What's happening?"
        self.textView.textColor = UIColor.lightGray
    }
    
    
    func checkAccess(){
        if PHPhotoLibrary.authorizationStatus() == .authorized{
            reloadAssets()
        } else{
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .notDetermined:
                    print("notDetermined")
                case .restricted:
                    print("restricted")
                case .denied:
                    self.presentCameraSettings()
                    print("denied")
                case .authorized:
                    print("authorized")
                    self.checkAccess()
                case .limited:
                    print("limited")
                    self.checkAccess()
                @unknown default:
                    print("default")
                }
            })
        }
        
    }
    
    func reloadAssets() {
        DispatchQueue.main.async {
            self.loader.startAnimating()
            self.assets = nil
            self.imageCollectionView.reloadData()
            self.assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil) as? PHFetchResult<AnyObject>
            self.imageCollectionView.reloadData()
            self.loader.stopAnimating()
        }
    }
    
    @IBAction func imageCloseBtnTapped(_ sender: Any) {
        self.imageCloseBtn.isHidden = true
        self.selectedImageView.image = nil
        self.imageCollectionView.isHidden = false
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        let postDict = NSMutableDictionary()
        let imgName = self.random()
        postDict.setValue("", forKey: "post_id")
        postDict.setValue("", forKey: "posted_time")
        postDict.setValue("", forKey: "suggested_type")
        postDict.setValue("", forKey: "suggested_by")
        postDict.setValue("0", forKey: "like_count")
        postDict.setValue("0", forKey: "reshared_count")
        postDict.setValue("0", forKey: "liked")
        postDict.setValue("0", forKey: "reshared")
        postDict.setValue(self.textView.text ?? "", forKey: "composed_detail")
        
        if selectedImageView.image != nil{
            Uitility.shared.store(image: (self.selectedImageView.image?.jpegData(compressionQuality: 10))!, forKey: imgName)
            postDict.setValue("image", forKey: "post_type")
            postDict.setValue(imgName, forKey: "composed_image_url")
        } else{
            postDict.setValue("text", forKey: "post_type")
            postDict.setValue("", forKey: "composed_image_url")
        }
        
        let userDeatil = NSMutableDictionary()
        userDeatil.setValue(ownUserDetatil.value(forKey: "userName"), forKey: "user_name")
        userDeatil.setValue(ownUserDetatil.value(forKey: "name"), forKey: "name")
        userDeatil.setValue(ownUserDetatil.value(forKey: "userImageUrl"), forKey: "user_image_url")
        postDict.setValue(userDeatil, forKey: "posted_by")
        
        let postModel = PostsModel.init(formJson: JSON(postDict))
        self.localStorage.saveOwnPost(recent: postModel)
        
        self.dismiss(animated: true, completion: {
            self.Success!()
        })
    }
    
    func random() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< 6 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return "\(ownUserDetatil.value(forKey: "userName") ?? "")\(randomString)"
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

//MARK: - CollectionView Delegate datasource
extension composeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assets != nil) ? assets!.count + 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "imagePickerCell", for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if indexPath.row == 0{
                (cell as! imagePickerCell).imageView.image = #imageLiteral(resourceName: "camera")
            } else{
                PHImageManager.default().requestImage(for: self.assets?[indexPath.row - 1] as! PHAsset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                    
                    (cell as! imagePickerCell).imageView.image = image//.image = image
                }
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.presentCameraVC()
        } else{
            PHImageManager.default().requestImage(for: self.assets?[indexPath.row - 1] as! PHAsset, targetSize: CGSize(width: 300, height: 150), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                self.imageCloseBtn.isHidden = false
                self.imageCollectionView.isHidden = true
                self.selectedImageView.image = image
            }
        }
        
    }
}
//MARK: - Picker deleagte
extension composeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func presentCameraVC(){
        self.textView.resignFirstResponder()
        self.collectionViewBottomConstraint.constant = 20
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            self.loader.startAnimating()
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: {
                self.loader.stopAnimating()
            })
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.selectedImageView.image = image
        self.imageCloseBtn.isHidden = false
        self.imageCollectionView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera or Library access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        present(alertController, animated: true)
    }
}


//MARK: - Textview delegate
extension composeVC :  UITextViewDelegate{
    
    @objc func keyBoardDidShow(_ notification:Notification)
    {
        self.collectionViewBottomConstraint.constant = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height
        print((notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= 2{
            self.postBtn.backgroundColor = .blue.withAlphaComponent(0.5)
            self.postBtn.isUserInteractionEnabled = false
        }
        if textView.text.count >= 3{
            self.postBtn.backgroundColor = .blue
            self.postBtn.isUserInteractionEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let compinedText = textView.text + text
        if compinedText.count >= 250{
            return false
        }
        return true
    }
    
}
