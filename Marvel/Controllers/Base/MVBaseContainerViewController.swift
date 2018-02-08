//
//  MVBaseContainerViewController.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/6/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit

class MVBaseContainerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView?
    
    var contentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.all
        
        if let vc = contentViewController {
            
            //setup container
            self.addChildViewController(vc)
            
            if let containerView = self.containerView {
                vc.view.frame = CGRect.init(x:0,
                                            y:0, width:containerView.frame.size.width, height:containerView.frame.size.height)
                containerView.addSubview(vc.view)
            } else {
                vc.view.frame = CGRect.init(x:0,y:0, width: vc.view.frame.size.width, height: vc.view.frame.size.height);
                view.addSubview(vc.view)
            }
            
            vc.didMove(toParentViewController: self)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    convenience init(viewController: UIViewController){
        self.init(nibName: nil, bundle: nil)
        self.contentViewController = viewController
    }
    
    convenience init(viewController: UIViewController, containerView: UIView){
        self.init(nibName: nil, bundle: nil)
        self.contentViewController = viewController
        self.containerView = containerView
    }
}
