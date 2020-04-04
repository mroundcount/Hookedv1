//
//  Extension.swift
//  Hooked
//
//  Created by Michael Roundcount on 3/7/20.
//  Copyright © 2020 Michael Roundcount. All rights reserved.
//

import Foundation
import SDWebImage


//This is for the design of the like and nope label
extension UILabel {
    func addCharacterSpacing(kernValue: Double = 3) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
//loading the card view in the nib file via it's class name (card) so load the card.xib file and return an instance of card
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

//UIImage class helper method
extension UIImageView {
    //pass the string url to the method as an optional
    func loadImage(_ urlString: String?, onSuccess: ((UIImage) -> Void)? = nil) {
        self.image = UIImage()
        //unwrap the URL string parameter
        guard let string = urlString else { return }
        //convert it to a url
        guard let url = URL(string: string) else { return }
        //the url is what we want to download the data from
        self.sd_setImage(with: url) { (image, error, type, url) in
            if onSuccess != nil, error == nil {
                onSuccess!(image!)
            }
        }
    }
}


extension UIImageView {
    func addBlackGradientLayer(frame: CGRect, colors:[UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.locations = [0.5, 1.0]
        
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
    }
}
