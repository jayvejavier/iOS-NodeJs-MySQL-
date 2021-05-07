//
//  CreateHeroViewController.swift
//  avengers_app
//
//  Created by Mospeng Research Lab Philippines on 8/12/20.
//  Copyright © 2020 Mospeng Research Lab Philippines. All rights reserved.
//

import UIKit
import SVProgressHUD

class CreateHeroViewController: UIViewController, UINavigationControllerDelegate {

    var imageFileName: String!
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var specialSkillTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, let specialSkill = specialSkillTextField.text, let imageFileName = imageFileName, let image = image else {
            return
        }
        
        if name != "" && specialSkill != "" && imageFileName != "" {
            
            SVProgressHUD.show(withStatus: "Posting...")
            print("Creating hero")
            APIService.shared.createHero(name: name, specialSkill: specialSkill, imageFileName: imageFileName, image: image) { (err) in
                if let err = err {
                    self.showAlert("Error", "Failed to create hero")
                    print("Failed to create hero object: ", err)
                    SVProgressHUD.dismiss()
                    return
                }
                print("Finsihed creating hero")
                self.nameTextField.text = ""
                self.specialSkillTextField.text = ""
                self.imageView.image = UIImage(named: "add_photo_icon")
                self.imageFileName = ""
                self.showAlert("Success", "Finsihed creating hero")
                SVProgressHUD.dismiss()
            }
        }
        else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        let imageViewTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(openPhotoLib))
        self.imageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderColor = UIColor.gray.cgColor
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.cornerRadius = 5
        let underlineButton: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.init(red: 0, green: 0, blue: 0, alpha: 1),
        .underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString = NSMutableAttributedString(string: "Submit" , attributes: underlineButton)
        self.submitButton.setAttributedTitle(attributeString, for: .normal)
    }
    
    @objc func openPhotoLib() {
        print("Opening photo library")
        
        let pickerPhoto = UIImagePickerController()
        pickerPhoto.sourceType = .photoLibrary
        pickerPhoto.allowsEditing = true
        pickerPhoto.delegate =  self
        self.present(pickerPhoto, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

}

extension CreateHeroViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var pickedImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
                   
            if picker.allowsEditing {
                pickedImage = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage)!
            }
            
            self.imageView.image = pickedImage
            
            if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                self.image = pickedImage
                print("imgUrl ", imgUrl)
                self.imageFileName = imgName
                print(imgName)
                let imgExtension = imgUrl.pathExtension
                print(imgExtension)
            }
        
            self.dismiss(animated: true)
        }
}
