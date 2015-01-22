//
//  AlbumsViewController.m
//  piwigo
//
//  Created by Spencer Baker on 1/20/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "AlbumsViewController.h"

#import "PiwigoImageData.h"
#import "DirectoryImageTableViewCell.h"
#import "NetworkHandler.h"
#import "ImageDetailViewController.h"

@interface AlbumsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *namesArray;

@end

@implementation AlbumsViewController

-(instancetype)init
{
	self = [super init];
	if(self)
	{
		self.view.backgroundColor = [UIColor whiteColor];
		
		self.tableView = [UITableView new];
		self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		[self.tableView registerClass:[DirectoryImageTableViewCell class] forCellReuseIdentifier:@"cell"];
		[self.view addSubview:self.tableView];
		[self.view addConstraints:[NSLayoutConstraint constraintFillSize:self.tableView]];
		
		[NetworkHandler getPost:nil success:^(id responseObject) {
			if([responseObject isKindOfClass:[NSDictionary class]]) {
				[self parseJSON:responseObject];
			}
		}];
	}
	return self;
}


-(void)parseJSON:(NSDictionary*)json
{
	NSDictionary *imagesInfo = [[json objectForKey:@"result"] objectForKey:@"images"];
	
	NSMutableArray *namesList = [NSMutableArray new];
	for(NSDictionary *image in imagesInfo)
	{
		PiwigoImageData *imgData = [PiwigoImageData new];
		imgData.file = [image objectForKey:@"file"];
		imgData.fullResPath = [image objectForKey:@"element_url"];
		
		NSDictionary *imageSizes = [image objectForKey:@"derivatives"];
		imgData.squarePath = [[imageSizes objectForKey:@"square"] objectForKey:@"url"];
		imgData.mediumPath = [[imageSizes objectForKey:@"medium"] objectForKey:@"url"];
		
		NSArray *categories = [image objectForKey:@"categories"];
		NSMutableArray *categoryIds = [NSMutableArray new];
		for(NSDictionary *category in categories)
		{
			[categoryIds addObject:[category objectForKey:@"id"]];
		}
		
		imgData.categoryIds = categoryIds;
		
		[namesList addObject:imgData];
	}
	self.namesArray = namesList;
	[self.tableView reloadData];
}


#pragma mark -- UITableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.namesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DirectoryImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	
	PiwigoImageData *imageData = self.namesArray[indexPath.row];
	cell.imageName.text = [NSString stringWithFormat:@"%@\t(%@)", imageData.file, [imageData.categoryIds firstObject]];
	
	NSURL *url = [NSURL URLWithString:imageData.squarePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	__weak UITableViewCell *weakCell = cell;
	[cell.imageView setImageWithURLRequest:request
						  placeholderImage:nil
								   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									   weakCell.imageView.image = image;
									   [weakCell setNeedsLayout];
								   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									   NSLog(@"error");
								   }];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	ImageDetailViewController *img = [ImageDetailViewController new];
	img.imageData = self.namesArray[indexPath.row];
	[self.navigationController pushViewController:img animated:YES];
	
}

@end