//
//  secondView.swift
//  Lab 1
//
//  Created by Paul Angelo Sy on 2/24/23.
//

import Foundation
import UIKit



class secondView: UIViewController{
    
    
    var name = ""
    var img : String = ""
    var types : [String] = []
    
    func createType(from string: String) -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedString(string + "-display-text", comment: "")
        label.layer.cornerRadius = 8.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor(named: string)
        return label
    }
    
    
    func setupImg() -> Void {
        if let url = URL(string: img) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    self.secondImage.image = UIImage(data: data)
                }
            }.resume()
        }
    }
    
    

        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        secondLabel.text = name
        DispatchQueue.main.async {
            self.setupImg()
        }
        stack.spacing = 10
        for type in types{
            stack.addArrangedSubview(createType(from: type))
        }
        
       
    }
    
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondImage: UIImageView!


}
