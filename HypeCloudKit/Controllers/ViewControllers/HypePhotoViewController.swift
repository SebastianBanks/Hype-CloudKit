//
//  HypePhotoViewController.swift
//  HypeCloudKit
//
//  Created by Sebastian Banks on 4/14/22.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    var hypeImage: UIImage?

    @IBOutlet weak var hypeTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTextField.text, !text.isEmpty,
              let image = hypeImage
        else { return }
        
        HypeController.shared.saveHype(with: text, photo: image) { success in
            if success {
                self.dismissView()
            }
        }
    }
    
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 10
        photoContainerView.clipsToBounds = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }

}

extension HypePhotoViewController: PhotoPickerDelegate {
    func photoPickerSelectedImage(image: UIImage) {
        self.hypeImage = image
    }
    
    
}
