//
//  CustomImageFlowLayout.swift
//  Timi
//
//  Created by Julien on 26/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .vertical
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 1
            let itemWidth = (self.collectionView!.frame.width - 16) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth*1.3)
        }
    }
}
