//
//  PiwigoAlbumData.h
//  piwigo
//
//  Created by Spencer Baker on 1/24/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiwigoImageData.h"

typedef enum {
	ImageListOrderId,
	ImageListOrderFileName,
	ImageListOrderName,
	ImageListOrderDate
} ImageListOrder;

@interface PiwigoAlbumData : NSObject

@property (nonatomic, assign) NSString *albumId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger globalRank;
@property (nonatomic, assign) NSInteger numberOfImages;
@property (nonatomic, assign) NSInteger albumThumbnailId;
@property (nonatomic, strong) NSString *albumThumbnailUrl;
@property (nonatomic, strong) NSDate *dateLast;

@property (nonatomic, readonly) NSArray *imageList;
@property (nonatomic, strong) NSArray *allKeysOrdered;
@property (nonatomic, readonly) NSDictionary *imageNameList;

-(void)addImages:(NSArray*)images;
-(void)sortImageList:(ImageListOrder)order;

@end
