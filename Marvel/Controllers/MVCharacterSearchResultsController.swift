//
//  MVCharacterSearchResultsController.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/7/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit


protocol CharactersSearchResultsControllerDelegate{
    func didSelectCharacter(character: MVCharacter)
    func changeSearchBarVisibility(visible: Bool)
}

class MVCharactersSearchResultsController: MVBaseContainerViewController {
    
    var delegate:CharactersSearchResultsControllerDelegate?
    
    var searchText: String = ""
    
    override func viewDidLoad() {
        
        if let charactersTableViewController = self.contentViewController as? MVCharactersTableViewController{
            charactersTableViewController.delegateDataSource = self
            charactersTableViewController.imageDelegate = self
            charactersTableViewController.delegate = self
        }
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
        self.delegate?.changeSearchBarVisibility(visible: true)
    }
    
}


extension MVCharactersSearchResultsController: ReusableTableViewControllerDataSourceDelegate{
    func dataWithLimit(limit: Int,
                       offset: Int,
                       completionHandler: @escaping(_ objects: Array<Any>?) -> Void) {
        MVApiManager.request.getCharachterSearch(text: self.searchText, limit: limit, offset: offset) { (ok, objects, error) in
            completionHandler(objects)
        }
    }
    
    func setupTableView(tableView: UITableView) {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
}


extension MVCharactersSearchResultsController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        if let charactersTableViewController = self.contentViewController as? MVCharactersTableViewController{
            charactersTableViewController.load()
        }
    }
    
}

extension MVCharactersSearchResultsController: ImageReusableTableViewControllerDelegate{
    func imageViewsForCell(cell: UITableViewCell, andObject object: Any, indexPath: IndexPath) -> [UIImageView] {
        if let characteCell = cell as? MVCharacterCell{
            if let imageView = characteCell.photoImageView{
                return [imageView]
            }
        }
        return []
    }
}

extension MVCharactersSearchResultsController: ReusableTableViewControllerDelegate{
    func didSelectObject(object: Any, atIndexPath indexPath: IndexPath) {
        if let character = object as? MVCharacter{
            self.delegate?.changeSearchBarVisibility(visible: false)
            self.navigationController?.pushViewController(UIStoryboard.detailsTableViewController(character: character), animated: true)
        }
    }
}
