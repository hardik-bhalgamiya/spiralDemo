//
//  AppRowCell.swift
//  VPracticalTask
//
//  Created by Hardik Bhalgamiya on 13/08/25.
//

import UIKit
import Cosmos

class AppRowCell: UITableViewCell {

    @IBOutlet weak var OuterContentView: UIView!
    
    @IBOutlet weak var buttonDownload: UIButton!
    
    @IBOutlet weak var iconImageview: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBOutlet weak var cosmoStartView: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonDownload.layer.cornerRadius = 17
        setupShadow()
    }

    private func setupShadow(){
        OuterContentView.layer.cornerRadius  = 10
        OuterContentView.layer.masksToBounds = false
        
        
        OuterContentView.layer.shadowColor = UIColor.green.cgColor
       // OuterContentView.layer.shadowOffset = CGSize(width: 5, height: 5)
        OuterContentView.layer.shadowRadius = 4
        OuterContentView.layer.shadowOpacity = 0.5
        
        
    }
    
    
}
