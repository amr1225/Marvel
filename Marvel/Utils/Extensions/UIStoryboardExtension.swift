//
//  UIStoryboardExtension.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    internal class func charactersTableViewController() -> MVCharactersTableViewController {
        //When the storyboarding class is loaded at runtime, the [.*]Class is referenced using a string.
        //The linker doesn't analyze code functionality, so it doesn't know that the class is used. Since no other source files references that class, the linker optimizes it out of existence when making the executable.
        MVCharactersTableViewController.hash()
        return mainStoryboard().instantiateViewController(withIdentifier: "CharactersTableViewController") as! MVCharactersTableViewController
        
    }
    
    
    internal class func searchCharactersViewController() -> MVCharactersTableViewController {
        MVCharactersTableViewController.hash()
        return mainStoryboard().instantiateViewController(withIdentifier: "SearchCharactersViewController") as! MVCharactersTableViewController
    }
    
    internal class func charactersSearchResultsController() -> MVCharactersSearchResultsController {
        return MVCharactersSearchResultsController(viewController: self.searchCharactersViewController())
    }
    
    
    
    internal class func charactersIndexViewController() -> MVCharactersIndexViewController {
        return MVCharactersIndexViewController(viewController: self.charactersTableViewController())
    }
    
    internal class func pictureCollectionViewController(character: MVCharacter) -> MVPictureCollectionViewController {
        let vc = mainStoryboard().instantiateViewController(withIdentifier: "PictureCollectionViewController") as! MVPictureCollectionViewController
        vc.character = character
        return vc
        
    }
    
    internal class func collectionContainer(character: MVCharacter) -> MVCollectionContainer {
        let vc = mainStoryboard().instantiateViewController(withIdentifier: "CollectionContainer") as! MVCollectionContainer
        let pvc = self.pictureCollectionViewController(character: character)
        pvc.enableCloseButton = true
        vc.contentViewController = pvc
        return vc
        
    }
    
    internal class func detailsTableViewController(character: MVCharacter) -> MVDetailsTableViewController {
        let vc = mainStoryboard().instantiateViewController(withIdentifier: "DetailsTableViewController") as! MVDetailsTableViewController
        vc.character = character
        return vc
        
    }
}
