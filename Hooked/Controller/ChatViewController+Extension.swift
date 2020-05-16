//
//  ChatViewController+Extension.swift
//  Hooked
//
//  Created by Michael Roundcount on 4/30/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

extension ChatViewController {
    func observeMessages() {
        
        Api.Message.receiveMessage(from: Api.User.currentUserId /*, to: Api.User.currentUserId*/) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
        /*
         Api.Message.receiveMessage(from: Api.User.currentUserId/*, to: Api.User.currentUserId*/) { (message) in
         self.messages.append(message)
         self.sortMessages()
         }
         */
    }
    
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupPicker() {
        picker.delegate = self
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupInputContainer() {
        let mediaImg = UIImage(named: "attachment_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mediaButton.setImage(mediaImg, for: UIControl.State.normal)
        //mediaButton.tintColor = .lightGray
        
        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        audioButton.setImage(micImg, for: UIControl.State.normal)
        audioButton.tintColor = .lightGray
        
        setupInputTextView()
    }
    
    func setupInputTextView() {
        
        inputTextView.delegate = self
        placeholderLbl.isHidden = false
        sendBtn.isEnabled = false
        sendBtn.setTitleColor(.lightGray, for: UIControl.State.normal)
        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        let placeholderFontSize = self.view.frame.size.width / 25
        
        placeholderLbl.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        placeholderLbl.text = "Write a message"
        placeholderLbl.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
        placeholderLbl.textColor = .lightGray
        placeholderLbl.textAlignment = .left
        
        inputTextView.addSubview(placeholderLbl)
    }
    
    func setupNativationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            self.avatarImageView.loadImage(user.profileImageUrl)
            self.avatarImageView.contentMode = .scaleAspectFill
            self.avatarImageView.layer.cornerRadius = 18
            self.avatarImageView.clipsToBounds = true
            containView.addSubview(self.avatarImageView)
            
            let rightBarButton = UIBarButtonItem(customView: containView)
            self.navigationItem.rightBarButtonItem = rightBarButton
            
            let Username = user.username
            let attributed = NSMutableAttributedString(string: Username + "\n" , attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.black])
            
            attributed.append(NSAttributedString(string: "Active", attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.green]))
            self.topLabel.attributedText = attributed
            self.navigationItem.titleView = self.topLabel
        }
    }
    
    func sendToFirebase(dict: Dictionary<String, Any>) {
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] = Api.User.currentUserId
        value["date"] = date
        value["read"] = true
        Api.Message.sendMessage(from: Api.User.currentUserId, /*to: Api.User.currentUserId,*/ value: value)
        //value["to"] = partnerId
        //value["to"] = Api.User.currentUserId
        //Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
    }
}


extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            let text = textView.text.trimmingCharacters(in: spacing)
            sendBtn.isEnabled = true
            sendBtn.setTitleColor(.black, for: UIControl.State.normal)
            placeholderLbl.isHidden = true
        } else {
            sendBtn.isEnabled = false
            sendBtn.setTitleColor(.lightGray, for: UIControl.State.normal)
            placeholderLbl.isHidden = false
        }
    }
    //Dismissing the keyboard. Looks for the repsonder to the text field to give up the startis
    func textView(_ inputTextView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            inputTextView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //had to use the NSURL to solve this issue https://stackoverflow.com/questions/58963716/uploading-video-to-firebase-using-putfile-swift-5
        //if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
        if let videoUrl = info[.mediaURL] as? NSURL {
            let url: URL = videoUrl.absoluteURL!
            handleVideoSelectedForUrl(url)
        } else {
            handleImageSelectedForInfo(info)
        }
    }

    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = imageSelected
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = imageOriginal
        }
        
        // save photo data
        let imageName = NSUUID().uuidString
        StorageService.savePhotoMessage(image: selectedImageFromPicker, id: imageName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    
    //video picker to mock up
    func handleVideoSelectedForUrl(_ url: URL) {
        // save video data
        let videoName = NSUUID().uuidString
        StorageService.saveVideoMessage(url: url, id: videoName, onSuccess: { (anyValue) in
            
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
            
        }) {
            (errorMessage) in
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    //selecting file documents
    //https://stackoverflow.com/questions/37296929/implement-document-picker-in-swift-ios
    func pickDocument() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeMP3)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first
            else {
            return
        }
        let audioName = NSUUID().uuidString
        print("import result : \(url)")
        print("my audio ID will be \(audioName)")
        
        StorageService.saveAudioMessage(url: url, id: audioName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) {
            (errorMessage) in
        }
    }
    
    func documentMenu(_ documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        //cell.playButton.isHidden = messages[indexPath.row].videoUrl == ""
        cell.playButton.isHidden = messages[indexPath.row].audioUrl == ""
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 60
        }
        
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage / widthMessage * 250)
        }
        return height
    }
}

