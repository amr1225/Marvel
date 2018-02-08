//
//  MVCollectionContainerViewController.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/7/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

class MVCollectionContainer: MVBaseContainerViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pagerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pictureCollectionViewController = self.contentViewController as? MVPictureCollectionViewController{
            pictureCollectionViewController.delegate = self
        }
    }
}

extension MVCollectionContainer: PictureCollectionViewControllerDelegate{
    func currentPageIndex(page: Int, pagesCount: Int){
        self.pagerLabel.text = "\(page)/\(pagesCount)"
    }
    func currentPageTitle(title: String){
        self.nameLabel.text = title
    }
}
