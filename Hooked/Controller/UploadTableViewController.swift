//
//  UploadTableViewController.swift
//  Hooked
//
//  Created by Michael Roundcount on 5/8/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import UIKit
import ProgressHUD
import MobileCoreServices
import AVFoundation

class UploadTableViewController: UITableViewController {
    
    var audioUrl: URL?
    var audioName: String?
    let genre = ["Rock", "Rap", "Classical"]
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var fileNameLbl: UILabel!
    @IBOutlet weak var genrePickerDidSelect: UIPickerView!
    @IBOutlet weak var genreLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeData()
        setupView()
        setUpEmailTxt()
    }
    
    func setupView() {
        //dismiss they keyboard with a tap gesture
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func observeData() {
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
        }
    }
    
    @IBAction func backBtnDidTap(_ sender: Any) {
        print("cancel")
        navigationController?.popViewController(animated: true)
    }

    @IBAction func uploadBtnDidTap(_ sender: Any) {
        print("opening browser")
        pickDocument()
    }
    
    @IBAction func saveBtnDidTap(_ sender: Any) {
        print("Saving")
        //ProgressHUD.show("Saving...")
        uploadDocument()
    }
    
    func setUpEmailTxt() {
        let placeholderAttr = NSAttributedString(string: "Song Title", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        titleTextField.attributedPlaceholder = placeholderAttr
        titleTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
}

extension UploadTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genre[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genre.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genreLbl.text = genre[row]
    }
    
}

extension UploadTableViewController: UIDocumentPickerDelegate {
    //setting docuementTyle limitation to only open MP3s
    func pickDocument() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeMP3)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //ProgressHUD.show("Uploading...")
        guard let url = urls.first
            else {
                return
        }
        self.audioUrl = url
        print("import result (not yet saved): \(url)")
        self.fileNameLbl.text = "FILE SELECTED"
    }
    
    func uploadDocument() {
        //https://stackoverflow.com/questions/51365956/swift-get-variable-in-function-from-another-function
        guard let url = audioUrl
            else {
                return
        }
        let audioName = NSUUID().uuidString
        print("my audio URL will be \(url)")
        print("my audio ID will be \(audioName)")
        
        StorageService.saveAudioFile(url: url, id: audioName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
                print(dict)
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
    
    func sendToFirebase(dict: Dictionary<String, Any>) {
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["artist"] = Api.User.currentUserId
        value["date"] = date
        value["read"] = true
        value["title"] = titleTextField.text
        value["genre"] = genreLbl.text
        Api.Audio.uploadAudio(artist: Api.User.currentUserId, value: value)
    }
}
