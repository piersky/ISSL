//
//  ItemTableViewCell.swift
//  InstantSharedShoppingList_iOS
//
//  Created by Pier Luigi Papeschi on 28/07/2019.
//  Copyright © 2019 Pier Luigi Papeschi. All rights reserved.
//

import UIKit

/*
 * Protocol for interaction between item and user
 */
protocol ChangeItemDelegate {
    func checkedPressed(cell: ItemTableViewCell)
    func deletePressed(cell: ItemTableViewCell)
    func editingItemEnded(cell: ItemTableViewCell)
}

class ItemTableViewCell: UITableViewCell {
    
    var delegate : ChangeItemDelegate?

    @IBOutlet var checkedBtn: UIButton!
    @IBOutlet var itemTextField: UITextField!
    
    var cellIndex: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func checkedBtnPressed(_ sender: Any) {
        delegate?.checkedPressed(cell: self)
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        delegate?.deletePressed(cell: self)
    }
    
    @IBAction func itemTextChangeEnded(_ sender: Any) {
        delegate?.editingItemEnded(cell: self)
    }
}

extension ItemTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
