//
//  MVCharactersTableViewcontroller.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/6/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

class MVCharactersTableViewController: MVImageReusableTableViewController<MVCharacter, MVCharacterCell> {
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        super.viewDidLoad()
    }
    
    override func cellIdentifier(forIndexPath indexPath: IndexPath) -> String {
        return Config.TableView.CellIdentifiers.CharacterCell
    }
    
    override func inflateCell(cell: MVCharacterCell, forObject object: MVCharacter, atIndexPath indexPath: IndexPath) {
        
        if(cell.backgroundView == nil){
            let imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.center
            cell.backgroundView = imageView
            cell.backgroundColor = UIColor.clear
        }
        
        super.inflateCell(cell: cell, forObject: object, atIndexPath: indexPath)
        cell.nameLabel.text = object.name
        
    }
    
    override func getImageHashForObject(object: MVCharacter, atIndexPath indexPath: IndexPath)->Int{
        return object.hashValue
    }
    
    override func imageViewsForCell(cell: UITableViewCell, andObject object: MVCharacter, indexPath: IndexPath) -> [UIImageView] {
        if let imageViews = imageDelegate?.imageViewsForCell(cell: cell, andObject: object, indexPath: indexPath){
            return imageViews
        }
        return [cell.backgroundView as! UIImageView]
    }
    
    
    
    override func image(imageView: UIImageView, object: MVCharacter, indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void) -> UIImage? {
        
        //try to download image
        if let localImage = MVRequest.getCharacterThumbnail(character: object, saveLocally: true, completionHandler: completionHandler) {
            return localImage
        }
        
        return super.image(imageView: imageView, object: object, indexPath: indexPath, completionHandler: completionHandler)
    }
    
}
