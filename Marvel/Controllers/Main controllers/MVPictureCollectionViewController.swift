//
//  MVPictureCollectionViewController.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/6/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit


protocol PictureCollectionViewControllerDelegate{
    func currentPageIndex(page: Int, pagesCount: Int)
    func currentPageTitle(title: String)
}


class MVPictureCollectionViewController: UICollectionViewController {
    
    var delegate: PictureCollectionViewControllerDelegate?
    
    var cache: ImageCache = ImageCache()
    
    var character: MVCharacter?
    
    private var items = [MVItem]()
    
    
    var enableCloseButton = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if let items = character?.comics.items{
            self.items = items
        }
        
        if enableCloseButton {
            // st up back button
            let closeButton = UIButton(frame: CGRect.init(x:self.view.frame.width - 50,y: 0,width: 30,height: 30))
            closeButton.setBackgroundImage(UIImage(named: "ImageClose"), for: UIControlState.normal)
            closeButton.addTarget(self, action: #selector(handleCloseButton(recognizer:)), for: .touchUpInside)
            self.view.addSubview(closeButton)
        }
        
    }
    
    @IBAction func handleCloseButton(recognizer: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.items.count>0{
            let item = self.items[0]
            delegate?.currentPageIndex(page: 1, pagesCount: self.items.count)
            delegate?.currentPageTitle(title: item.name)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.cache.clear()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.TableView.CellIdentifiers.ItemCell, for: indexPath)
        
        let item = items[indexPath.row]
        
        let hashValue = item.hashValue
        let storagePath = Config.StorageFilePaths.resourceComicsPath(name: String(hashValue))
        
        if let imageView = cell.backgroundView as? UIImageView{
            //TODO: add placeholder
            imageView.image = nil
        }
        
        if let image = self.cache.get(hash: hashValue) {
            
            if let imageView = cell.backgroundView as? UIImageView{
                imageView.image = image
            }else{
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                cell.backgroundView = imageView
            }
            
        } else {
            
            Utilities.queues.asyncQueue.addOperation({
                if let localImage = ImageUtilities.getImage(path: storagePath){
                    self.addImageToCacheAndRefreshItems(hashValue: hashValue, image: localImage, indexPath: indexPath as IndexPath)
                }else{
                    let url = item.resourceURI
                    
                    MVApiManager.request.getComic(url: url as URL, completionHandler: { (ok: Bool, objects: [MVComic]?, error: Error?) in
                        if let comic = objects?.first{
                            MVAPI().downloadImage(url: comic.thumbnailURI as URL, storageFilePaths: storagePath, completionHandler: { (image) in
                                if image != nil{
                                    self.addImageToCacheAndRefreshItems(hashValue: hashValue, image: image!, indexPath: indexPath)
                                }
                            })
                        }
                    })
                    
                }
            })
        }
        
        // Configure the cell
        return cell
    }
    private func addImageToCacheAndRefreshItems(hashValue: Int, image: UIImage, indexPath: IndexPath){
        self.cache.add(hash: hashValue, value: image)
        DispatchQueue.main.async {
            if (self.collectionView?.cellForItem(at: indexPath) != nil){
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let visibleRect = CGRect(origin: self.collectionView!.contentOffset, size: self.collectionView!.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let visibleIndexPath = self.collectionView?.indexPathForItem(at: visiblePoint){
            
            let index = visibleIndexPath.row
            let item = self.items[index]
            
            delegate?.currentPageIndex(page: index+1, pagesCount: self.items.count)
            delegate?.currentPageTitle(title: item.name)
        }
        
    }
}

