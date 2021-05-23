//
//  ListTableViewCell.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 12/10/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit

protocol ListClickedDelegate {
    func listPressed(cell: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    
    var delegate : ListClickedDelegate?
    
    @IBOutlet var listNameTextField: UILabel!
    @IBOutlet var listInfosLabel: UILabel!
    
    var cellIndex: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
