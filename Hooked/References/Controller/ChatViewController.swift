//
//  ChatViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 4/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import ProgressHUD

class ChatViewController: UIViewController {

    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePartner: UIImage!
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var partnerId: String!
    var placeholderLbl = UILabel()
    var picker = UIImagePickerController()
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        setupInputContainer()
        setupNativationBar()
        setupTableView()
        observeMessages()
        
        inputTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
        
    @IBAction func sendBtnDidTapped(_ sender: Any) {
        if let text = inputTextView.text, text != "" {
            inputTextView.text = ""
            self.textViewDidChange(inputTextView)
            sendToFirebase(dict: ["text": text as Any])
        }
    }
    
    @IBAction func fileBtnDidTapped(_ sender: Any) {
        pickDocument()
    }
        
    //uploading media
    //Review lecture 35 notes for plist requirements
    @IBAction func mediaBtnDidTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Hooked", message: "Select source", preferredStyle: UIAlertController.Style.actionSheet)
        
        let library = UIAlertAction(title: "Choose an Image or a video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie), String(kUTTypeMP3)]
                if #available(iOS 11.0, *) {
                    self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                }
                
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(library)
        
        present(alert, animated: true, completion: nil)
    }
}

