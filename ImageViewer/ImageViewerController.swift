//
//  ImageViewerController.swift
//  ImageViewer
//
//  Created by Ky Nguyen on 10/9/15.
//  Copyright © 2015 Ky Nguyen. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController, UIScrollViewDelegate {

    var image = UIImage()
    var imageView = UIImageView()
    var pan = UIPanGestureRecognizer()
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        // setup scrollview 
        scrollView = UIScrollView(frame: view.frame)
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // register taps 
        let tapOnce = UITapGestureRecognizer.init(target: self, action: Selector("tapOnceAction"))
        
        let tapTwice = UITapGestureRecognizer.init(target: self, action: Selector("tapTwiceAction:"))
        
        tapOnce.numberOfTapsRequired = 1
        tapTwice.numberOfTapsRequired = 2
        tapOnce.requireGestureRecognizerToFail(tapTwice)
        
        scrollView.addGestureRecognizer(tapOnce)
        scrollView.addGestureRecognizer(tapTwice)
    }

    func setupView() {
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        // setup scrollview
        scrollView = UIScrollView(frame: view.frame)
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // register taps
        let tapOnce = UITapGestureRecognizer.init(target: self, action: Selector("tapOnceAction"))
        
        let tapTwice = UITapGestureRecognizer.init(target: self, action: Selector("tapTwiceAction:"))
        
        tapOnce.numberOfTapsRequired = 1
        tapTwice.numberOfTapsRequired = 2
        tapOnce.requireGestureRecognizerToFail(tapTwice)
        
        scrollView.addGestureRecognizer(tapOnce)
        scrollView.addGestureRecognizer(tapTwice)
    }
    
    func centerPictureFromPoint(point: CGPoint, ofSize size: CGSize, withCornerRadius radius: CGFloat) {
        
        imageView = UIImageView(frame: CGRectMake(point.x, point.y, size.width, size.height))
        imageView.layer.cornerRadius = radius
        imageView.clipsToBounds = true
        
        imageView.image = image
        scrollView.addSubview(imageView)

        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            let imageWidth = self.image.size.width
            let imageHeight = self.image.size.height
            let imageRatio = imageWidth / imageHeight
            let viewRatio = self.view.frame.size.width / self.view.frame.size.height
            
            var ratio: CGFloat = 0
            if imageRatio >= viewRatio {
                
                ratio = imageWidth / self.view.frame.size.width
            }
            else {
                
                ratio = imageHeight / self.view.frame.size.height
            }
            
            let newWidth = imageWidth / ratio
            let newHeight = imageHeight / ratio
            self.imageView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, newWidth, newHeight)
            self.imageView.center = self.scrollView.center
            self.imageView.layer.cornerRadius = 0.0
            self.view.backgroundColor = UIColor.blackColor()
            }) { (Bool) -> Void in
                
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
                
                self.pan = UIPanGestureRecognizer.init(target: self, action: Selector("moveImage:"))

                self.scrollView.addGestureRecognizer(self.pan)
        }
        
    }

    func tapOnceAction() {
        
        if self.scrollView.zoomScale != self.scrollView.minimumZoomScale {
            
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func tapTwiceAction(gestureRecognizer: UIGestureRecognizer) {
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            
            let zoomRect = zoomRectForScale(scrollView.maximumZoomScale, withCenter: gestureRecognizer.locationInView(gestureRecognizer.view))
            
            scrollView.zoomToRect(zoomRect, animated: true)
        }
        else {
            
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, var withCenter center: CGPoint) -> CGRect {
        
        var zoomRect = CGRect()
        
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        center = imageView.convertPoint(center, fromView: self.view)
        zoomRect.origin.x = center.x - ((zoomRect.size.width / 2))
        zoomRect.origin.y = center.y - ((zoomRect.size.height / 2))
        
        return zoomRect
    }
    
    func moveImage(gesture: UIPanGestureRecognizer) {
        
        let deltaY = gesture.translationInView(self.scrollView).y
        let translatedPoint = CGPointMake(self.view.center.x, self.view.center.y + deltaY)
        self.scrollView.center = translatedPoint
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            let velocityY = gesture.velocityInView(scrollView).y
            let maxDeltaY = (self.view.frame.size.height - self.imageView.frame.size.height) / 2

            // swipe down
            if velocityY > 700 || (abs(deltaY) > maxDeltaY && deltaY > 0) {
                
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.view.frame.size.height, self.imageView.frame.size.width, self.imageView.frame.size.height)
                    
                    self.view.alpha = 0.0
                    }, completion: { (Bool) -> Void in
                        
                        self.view.removeFromSuperview()
                })
            }
                
                // swipe up
            else if velocityY < -700 || (abs(deltaY) > maxDeltaY && deltaY < 0) {
                
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, -self.imageView.frame.size.height, self.imageView.frame.size.width, self.imageView.frame.size.height)
                    self.view.alpha = 0.0
                    }, completion: { (Bool) -> Void in
                        
                        self.view.removeFromSuperview()
                })
            }
            else {
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    
                    self.scrollView.center = self.view.center
                })
            }
        }
    }

    func centerScrollViewContents() {
        
        let boundSize = self.scrollView.bounds.size
        var contentFrame = self.imageView.frame
        
        if (contentFrame.size.width < boundSize.width) {
            
            contentFrame.origin.x = (boundSize.width - contentFrame.size.width) / 2
        }
        else {
            
            contentFrame.origin.x = 0.0
        }
        
        if contentFrame.size.height < boundSize.height {
            
            contentFrame.origin.y = (boundSize.height - contentFrame.size.height) / 2
        }
        else {
            
            contentFrame.origin.y = 0.0
        }
        
        imageView.frame = contentFrame
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        centerScrollViewContents()
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            
            scrollView.addGestureRecognizer(pan)
        }
        else {
            
            scrollView.removeGestureRecognizer(pan)
        }
    }

}

