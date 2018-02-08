//
//  MVImageReusableTableViewController.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/6/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

@objc protocol ImageReusableTableViewControllerDelegate{
    func imageViewsForCell(cell: UITableViewCell, andObject object: Any, indexPath: IndexPath) -> [UIImageView]
}

class MVImageReusableTableViewController<T, C: UITableViewCell>: MVReusableTableViewController<T, C>{
    
    var imageDelegate: ImageReusableTableViewControllerDelegate?
    
    var caches: [ImageCache]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        caches = [ImageCache]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        for cache: ImageCache in self.caches{
            cache.clear()
        }
    }
    
    func getImageHashForObject(object: T, atIndexPath indexPath: IndexPath)->Int{
        return 0
    }
    
    func placeholderForImageView(imageView: UIImageView, andObject object: T, indexPath: IndexPath) -> UIImage? {
        return UIImage.imageWithColor(color: UIColor.black)
    }
    
    func image(imageView: UIImageView, object: T, indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void) -> UIImage? {
        return nil
    }
    
    func imageViewsForCell(cell: C, andObject object: T, indexPath: IndexPath) -> [UIImageView]{
        let obj = object
        if let imageViews = imageDelegate?.imageViewsForCell(cell: cell, andObject: obj as Any, indexPath: indexPath){
                return imageViews
        }
        return []
    }
    
    override func inflateCell(cell: C, forObject object: T, atIndexPath indexPath: IndexPath) {
        
        super.inflateCell(cell: cell, forObject: object, atIndexPath: indexPath)
        
        let imageViews = self.imageViewsForCell(cell: cell, andObject: object, indexPath: indexPath)
        
        if (imageViews.count>0) {
            
            if (self.caches.count < imageViews.count) {
                for _ in (self.caches.count-1)...(imageViews.count-1) {
                    self.caches.append(ImageCache())
                }
                
            }
            
            for index in 0...(imageViews.count-1){
                let imageView = imageViews[index]
                imageView.tag = index
                self.inflateImageView(imageView: imageView, forObject: object, indexPath: indexPath, withCache: self.caches[index])
            }
        }
        
    }
    
    private func inflateImageView(imageView: UIImageView, forObject object: T, indexPath: IndexPath, withCache cache: ImageCache){
        
        let hashValue =  self.getImageHashForObject(object: object, atIndexPath: indexPath)
        
        if let image = cache.get(hash: hashValue) {
            imageView.image = image
        } else {
            //set placeholder and proceed
            imageView.image = self.placeholderForImageView(imageView: imageView, andObject: object, indexPath: indexPath)
            
            Utilities.queues.asyncQueue.addOperation({
                () -> Void in
                
                if let localImage = self.image(imageView: imageView, object: object, indexPath:indexPath, completionHandler: {
                    (image: UIImage?) -> Void in
                    if (image != nil) {
                        
                        cache.add(hash: hashValue, value: image!)
                        DispatchQueue.main.async {
                            if self.tableView.cellForRow(at: indexPath) != nil {
                                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                            }
                        }
                    
                        
                    }
                }) {
                    DispatchQueue.main.async {
                        imageView.image = localImage
                    }
                }
                
            })
        }
        
        
    }
    
}

class ImageCache{
    private var cache: [Int:UIImage]
    
    init() {
        self.cache = [Int: UIImage]()
    }
    
    func add(hash: Int, value: UIImage) {
        self.cache[hash] = value
    }
    func get(hash: Int)->UIImage? {
        return self.cache[hash]
    }
    
    func clear() {
        self.cache.removeAll()
    }
}
