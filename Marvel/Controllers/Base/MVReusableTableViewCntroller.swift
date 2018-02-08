//
//  MVReusableTableViewCntroller.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/7/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//


import UIKit

@objc protocol ReusableTableViewControllerDataSourceDelegate {
    func dataWithLimit(limit: Int, offset: Int, completionHandler: @escaping (_ objects: Array<Any>?) -> Void)
    @objc optional func inflateCell(cell: UITableViewCell, object: Any, indexPath: IndexPath)
    @objc optional func setupTableView(tableView: UITableView)
}

@objc protocol ReusableTableViewControllerDelegate {
    func didSelectObject(object: Any, atIndexPath indexPath: IndexPath)
}


class MVReusableTableViewController<T, C:UITableViewCell>: UITableViewController {
    
    var delegateDataSource: ReusableTableViewControllerDataSourceDelegate?
    var delegate: ReusableTableViewControllerDelegate?
    
    
    private let loadMoreOffset: CGFloat = 42.0
    private var loadMoreIndicator: UIView!
    
    private var newDataLoadingEnabled: Bool!
    private var isFetching: Bool!
    private var previousScrollViewYOffset: CGFloat = 0
    private var threshold: CGFloat!
    private var pointNow: CGPoint = CGPoint.zero
    
    
    internal(set) var objects: [T]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.threshold = 40
        self.isFetching = false
        self.newDataLoadingEnabled = true
        
        //setup load more view
        let loadMoreIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadMoreIndicator.startAnimating()
        self.loadMoreIndicator = loadMoreIndicator
        
        //set up refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MVReusableTableViewController.refresh), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        self.objects = [T]()
        load()
        self.delegateDataSource?.setupTableView?(tableView: self.tableView)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(forIndexPath: indexPath), for: indexPath as IndexPath) as! C
        let object = self.objectAtIndexPath(indexPath: indexPath)
        self.inflateCell(cell: cell, forObject: object, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return objects.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfObjectsForLoad() -> Int {
        return Config.TableView.listLoadLimit
    }
    
    
    func objectAtIndexPath(indexPath: IndexPath) -> T {
        return objects[indexPath.row]
    }
    
    func cellIdentifier(forIndexPath indexPath: IndexPath) -> String {
        return Config.TableView.CellIdentifiers.CharacterCell
    }
    
    func inflateCell(cell: C, forObject object: T, atIndexPath indexPath: IndexPath) {
        self.delegateDataSource?.inflateCell?(cell: cell, object: object as Any, indexPath: indexPath)
    }
    
    func dataWithLimit(limit: Int, offset: Int, completionHandler: @escaping (_ objects:Array<Any>?) -> Void) {
        self.delegateDataSource?.dataWithLimit(limit: limit, offset: offset, completionHandler: completionHandler)
    }
    
    //internal callback
    @IBAction func refresh() {
        
        let limit = self.numberOfObjectsForLoad()
        let offset = 0
        
        self.handleFetching(limit: limit, offset: offset, before: {
            self.refreshControl?.beginRefreshing()
        }) { (objects) in
            DispatchQueue.main.async {
                //load table with new objects
                if(objects != nil){
                    self.loadData(objects: objects!)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
        
    
    func load() {
        let limit = self.numberOfObjectsForLoad()
        let offset = 0
        
        self.handleFetching(limit: limit, offset: offset, before: {
            
        }) { (objects) in
            DispatchQueue.main.async {
                self.loadData(objects: objects)
            }
        }
    }
    
    //call to update table with new objects (should be executed on main thread)
    func loadData(objects: [T]?) {
        
        if objects != nil {
            self.objects = objects!
        } else {
            self.objects = [T]()
        }
        self.tableView.reloadData()
    }
    
     func scrollDelegateHelper(scrollView: UIScrollView) {
        let scrollSpeed = scrollView.contentOffset.y - previousScrollViewYOffset;
        previousScrollViewYOffset = scrollView.contentOffset.y;
        if abs(scrollSpeed) > threshold {
            if (scrollView.contentOffset.y < pointNow.y) {
                //down
                // self.scrollViewDidAccelerateUp(false)
                
            } else if (scrollView.contentOffset.y > pointNow.y) {
                // self.scrollViewDidAccelerateUp(true)
            }
            
        }
        
    }
    
    
     func handleFetching(limit: Int,
                         offset: Int,
                         before: @escaping () -> Void,
                         after: @escaping ([T]?) -> Void) {
        before()
        self.dataWithLimit(limit: limit, offset: offset) { (objects) in
            //enable load more
            self.newDataLoadingEnabled = true
            
            if objects != nil {
                var newObjects = [T]()
                for object in objects! {
                    newObjects.append(object as! T)
                }
                after(newObjects)
            }else{
                after(nil)
            }
        }
        
    }
        


    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset;
    }
    
    override  func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (Int(scrollView.contentOffset.y + scrollView.frame.size.height + self.loadMoreOffset) >= Int(scrollView.contentSize.height + scrollView.contentInset.bottom)) {
            if (newDataLoadingEnabled == true && isFetching == false) {
                
                let limit = self.numberOfObjectsForLoad()
                
                let offset = self.objects.count
                
                self.handleFetching(limit: limit, offset: offset, before: {
                    
                    self.isFetching = true
                    self.tableView.tableFooterView = self.loadMoreIndicator
                    self.tableView.scrollRectToVisible(self.tableView.tableFooterView!.frame, animated: true)
                }) {(newObjects) in
                    
                    sleep(1)
                    
                    var indexPaths = [IndexPath]()
                    if newObjects != nil && newObjects!.count != 0 {
                        //append new objects to array of objects
                        for index in 0...(newObjects!.count-1){
                            let newObject = newObjects![index]
                            self.objects.append(newObject)
                            indexPaths.append(IndexPath(row: (self.objects.count-1), section: 0))
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        if newObjects != nil {
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: indexPaths as [IndexPath], with: UITableViewRowAnimation.fade)
                            self.tableView.endUpdates()
                        }
                        
                        if newObjects == nil || newObjects!.count == 0 {
                            //disable fetching permanently
                            self.newDataLoadingEnabled = false
                        }
                        
                        //hide footer with loading view
                        self.tableView.tableFooterView = nil
                        self.isFetching = false
                    }
                }
            }
        } else {
            self.scrollDelegateHelper(scrollView: scrollView)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let object = self.objectAtIndexPath(indexPath: indexPath)
        self.delegate?.didSelectObject(object: object as Any, atIndexPath: indexPath)

    }
    
}
