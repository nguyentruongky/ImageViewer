//
//  ViewController.swift
//  ImageViewer
//
//  Created by Ky Nguyen on 10/9/15.
//  Copyright © 2015 Ky Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var krabiButton = UIButton()
    
    var beachButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        krabiButton = UIButton(type: UIButtonType.Custom)
        krabiButton.frame = CGRectMake(100, 200, 100, 100)
        krabiButton.addTarget(self, action: Selector("onTapKrabi"), forControlEvents: UIControlEvents.TouchUpInside)
        krabiButton.setImage(UIImage(named: "1.png"), forState: UIControlState.Normal)
        krabiButton.exclusiveTouch = true
        view.addSubview(krabiButton)
        
        beachButton = UIButton(type: UIButtonType.Custom)
        beachButton.frame = CGRectMake(0, 0, 200, 100)
        beachButton.addTarget(self, action: Selector("onTapBeach"), forControlEvents: UIControlEvents.TouchUpInside)
        beachButton.setImage(UIImage(named: "2.png"), forState: UIControlState.Normal)
        beachButton.exclusiveTouch = true
        view.addSubview(beachButton)

    }

    
    func onTapBeach() {
        
        let imageViewerController = ImageViewerController()
        imageViewerController.image = (beachButton.imageView?.image)!
        view.addSubview(imageViewerController.view)
        imageViewerController.centerPictureFromPoint(beachButton.frame.origin, ofSize: beachButton.frame.size)
    }


    func onTapKrabi() {

        let imageViewerController = ImageViewerController()
        imageViewerController.image = (krabiButton.imageView?.image)!
        view.addSubview(imageViewerController.view)
        imageViewerController.centerPictureFromPoint(krabiButton.frame.origin, ofSize: krabiButton.frame.size)
    }

}

