//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Remus Lazar on 30.05.15.
//  Copyright (c) 2015 Remus Lazar. All rights reserved.
//

import UIKit

private struct Colors {
    static let hashtag = UIColor.brownColor()
    static let url = UIColor.blueColor()
    static let screenName = UIColor.grayColor()
}

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet {
            tweetTextLabel?.attributedText = tweet.attributedText
            if tweetTextLabel?.text != nil {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet user description
            
            if let profileImageURL = tweet.user.profileImageURL {
                tweetProfileImageView?.image = nil
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                    let imageData = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil && profileImageURL == tweet.user.profileImageURL {
                            // the cell may have been reused, so we check if the url we fetched is still
                            // the correct url for the current cell
                            self.tweetProfileImageView?.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
        }
        
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
}

private extension Tweet {
    var attributedText: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            // make sure we're using the preferred font for body text
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            ]
        )
        for tag in hashtags {
            attributedString.addAttribute(NSForegroundColorAttributeName,
                value: Colors.hashtag, range: tag.nsrange)
        }
        for tag in urls {
            attributedString.addAttribute(NSForegroundColorAttributeName,
                value: Colors.url, range: tag.nsrange)
        }
        for tag in userMentions {
            attributedString.addAttribute(NSForegroundColorAttributeName,
                value: Colors.screenName, range: tag.nsrange)
        }
        return attributedString
    }
}
