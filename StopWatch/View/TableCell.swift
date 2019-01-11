//
//  TableCell.swift
//  StopWatch
//
//  Created by Hsuen-Ju Li on 2019/1/11.
//  Copyright © 2019 Hsuen-Ju Li. All rights reserved.
//

import UIKit

class TableCell : UITableViewCell {
    
    //Outlet
    var time : Time?{
        didSet{
            let dateFormmater = DateFormatter()
            dateFormmater.dateFormat = "yyyy/MM/dd"
            let dateString = dateFormmater.string(from: (time?.date)!)
            dateLabel.text = dateString
            timeLabel.text = time?.timeLabel
        }
    }
    
    var dateLabel : UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textColor = .white
        label.backgroundColor = UIColor.lightGray
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    let timeLabel : UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(dateLabel)
        addSubview(timeLabel)
        
        dateLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 20, paddingBottom: 5, paddingRight: 0, width: 100, height: 30)
        
        timeLabel.anchor(top: topAnchor, left: dateLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


