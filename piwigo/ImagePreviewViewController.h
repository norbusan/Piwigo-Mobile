//
//  ImagePreviewViewController.h
//  piwigo
//
//  Created by Spencer Baker on 2/21/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PiwigoImageData;
@class ImageScrollView;

@protocol ImagePreviewDelegate <NSObject>

-(void)downloadProgress:(CGFloat)progress;

@end

@interface ImagePreviewViewController : UINavigationController

@property (nonatomic, weak) id<ImagePreviewDelegate> imagePreviewDelegate;
@property (nonatomic, strong) ImageScrollView *scrollView;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) BOOL imageLoaded;

-(void)setImageWithImageData:(PiwigoImageData*)imageData;

@end
