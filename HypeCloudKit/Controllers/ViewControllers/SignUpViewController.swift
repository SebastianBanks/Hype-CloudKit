//
//  SignUpViewController.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/13/22.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var profilePhoto: UIImage?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUser()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let bio = bioTextField.text
        else { return }
        
        UserController.shared.createUser(with: username, bio: bio, profilePhoto: profilePhoto) { (success) in
            if success {
                self.presentHypeListVC()
            }
        }
    }
    
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 2
        photoContainerView.clipsToBounds = true
    }
    
    func fetchUser() {
        UserController.shared.fetchUser { (success) in
            if success {
                self.presentHypeListVC()
            }
        }
    }
    
    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }

}

extension SignUpViewController: PhotoPickerDelegate {
    
    func photoPickerSelectedImage(image: UIImage) {
        self.profilePhoto = image
    }
}
