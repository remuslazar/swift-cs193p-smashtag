//
//  ImageViewController.swift
//  Cassini
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    // our Model
    // publicly settable
    // when it changes (but only if we are on screen)
    //   we'll fetch the image from the imageURL
    // if we're off screen when this happens (view.window == nil)
    //   viewWillAppear will get it for us later
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    // fetches the image at imageURL
    // does so off the main thread
    // then puts a closure back on the main queue
    //   to handle putting the image in the UI
    //   (since we aren't allowed to do UI anywhere but main queue)
    private func fetchImage()
    {
        if let url = imageURL {
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: url) // this blocks the thread it is on
                dispatch_async(dispatch_get_main_queue()) {
                    // only do something with this image
                    // if the url we fetched is the current imageURL we want
                    // (that might have changed while we were off fetching this one)
                    if url == self.imageURL { // the variable "url" is capture from above
                        if imageData != nil {
                            // this might be a waste of time if our MVC is out of action now
                            // which it might be if someone hit the Back button
                            // or otherwise removed us from split view or navigation controller
                            // while we were off fetching the image
                            self.image = UIImage(data: imageData!)
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size // critical to set this!
            scrollView.delegate = self                    // required for zooming
            scrollView.minimumZoomScale = 0.03            // required for zooming
            scrollView.maximumZoomScale = 4.0             // required for zooming
        }
    }
    
    // UIScrollViewDelegate method
    // required for zooming
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var userDidDragOrScroll = false
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userDidDragOrScroll = true
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        userDidDragOrScroll = true
    }
    
    // do a pan-and-scan zooming of the content area
    private func scaleContentPanAndScan() {

        // reset the scrollView to the initial state
        scrollView.contentOffset = CGPointZero
        scrollView.zoomScale = 1.0
        
        let content = scrollView.contentSize
        let viewport = scrollView.bounds.size
        
        let rect: CGRect, scaleFactor: CGFloat, minimumZoomScale: CGFloat
        
        if (content.width / content.height > viewport.width / viewport.height) {
            // our content is wider than the viewport
            // for "pan and zoom" we scale the content to its height and
            // center it horizontally
            scaleFactor = viewport.height / content.height
            let newWidth = viewport.width / scaleFactor
            rect = CGRect(x: (content.width - newWidth) / 2, y: 0, width: newWidth, height: content.height)
            minimumZoomScale = viewport.width / content.width
        } else {
            // now the viewport is wider than the content
            // we scale the content to its width and
            // center it vertically
            scaleFactor = viewport.width / content.width
            let newHeight = viewport.height / scaleFactor
            rect = CGRect(x: 0, y: (content.height - newHeight) / 2, width: content.width, height: newHeight)
            minimumZoomScale = viewport.height / content.height
        }
        
        // set it to the scaleFactor, but also allow 1:1 zooming, if the image is highres
        // this allows also lowres images to be displayed full-screen
        scrollView.maximumZoomScale = max(1.0, scaleFactor)

        // dont allow to zoom our more than letterbox aspect ratio
        scrollView.minimumZoomScale = minimumZoomScale
        
        scrollView.zoomToRect(rect, animated: false)
    }
    
    private var imageView = UIImageView()
    
    // convenience computed property
    // lets us get involved every time we set an image in imageView
    // we can do things like resize the imageView,
    //   set the scroll view's contentSize,
    //   and stop the spinner
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            
            if (scrollView != nil) {
                scrollView.contentSize = imageView.bounds.size
                scaleContentPanAndScan()
            }
            spinner?.stopAnimating()
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!userDidDragOrScroll && scrollView != nil && imageView.image != nil) {
            scaleContentPanAndScan()
        }
    }
    
    // put our imageView into the view hierarchy
    // as a subview of the scrollView
    // (will install it into the content area of the scroll view)
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // for efficiency, we will only actually fetch the image
    // when we know we are going to be on screen
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    private let doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        return recognizer
    }()
    
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer! {
        didSet {
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        }
    }
    
    
    @IBAction func tapGesture(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
