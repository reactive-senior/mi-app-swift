//
//  CustomImageFlowLayout.swift
//  Timi
//
//  Created by Julien on 26/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

class CustomImageFlowLayoutlieux: UICollectionViewFlowLayout {
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
            let itemWidth = (self.collectionView!.frame.width ) / numberOfColumns
            let itemHeight = (self.collectionView!.frame.height)

            return CGSize(width: itemWidth, height: itemHeight*0.9)
        }
    }
}
