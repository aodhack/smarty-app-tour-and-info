//
//  CommentTableViewCell.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var comment: Comment!
    
    var delegate: RateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func good(_ sender: UIButton) {
        delegate?.good(comment: comment)
    }
    
    @IBAction func bad(_ sender: UIButton) {
        delegate?.bad(comment: comment)
    }
    
}
