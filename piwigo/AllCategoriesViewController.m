//
//  AllCategoriesViewController.m
//  piwigo
//
//  Created by Spencer Baker on 3/16/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "AllCategoriesViewController.h"
#import "CategoriesData.h"
#import "AlbumService.h"

@interface AllCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger imageId;
@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, strong) UITableView *categoriesTableView;

@end

@implementation AllCategoriesViewController

-(instancetype)initForImageId:(NSInteger)imageId andCategoryId:(NSInteger)categoryId
{
	self = [super init];
	if(self)
	{
		self.view.backgroundColor = [UIColor piwigoWhiteCream];
		self.title = NSLocalizedString(@"categorySelection", @"Select Album");
		self.imageId = imageId;
		self.categoryId = categoryId;
		
		self.categoriesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		self.categoriesTableView.translatesAutoresizingMaskIntoConstraints = NO;
		self.categoriesTableView.delegate = self;
		self.categoriesTableView.dataSource = self;
		self.categoriesTableView.backgroundColor = [UIColor piwigoWhiteCream];
		[self.view addSubview:self.categoriesTableView];
		[self.view addConstraints:[NSLayoutConstraint constraintFillSize:self.categoriesTableView]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryDataUpdated) name:kPiwigoNotificationCategoryDataUpdated object:nil];
			
	}
	return self;
}

-(void)categoryDataUpdated
{
	[self.categoriesTableView reloadData];
}

#pragma mark UITableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
	{
		return 1;
	}
	return [CategoriesData sharedInstance].allCategories.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 1)
	{
		return 0;
	}
	return 50.0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
		
		UILabel *headerLabel = [UILabel new];
		headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
		headerLabel.font = [UIFont piwigoFontNormal];
		headerLabel.textColor = [UIColor piwigoGray];
		headerLabel.text = NSLocalizedString(@"categorySelection_forImage", @"Select an album for this image");
		headerLabel.adjustsFontSizeToFitWidth = YES;
		headerLabel.minimumScaleFactor = 0.5;
		[header addSubview:headerLabel];
		[header addConstraint:[NSLayoutConstraint constraintViewFromBottom:headerLabel amount:10]];
		[header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[header]-15-|"
																	   options:kNilOptions
																	   metrics:nil
																		 views:@{@"header" : headerLabel}]];
		
		return header;
	}
	return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
		}
		
		PiwigoAlbumData *albumData = [[CategoriesData sharedInstance].allCategories objectAtIndex:indexPath.row];
		
		cell.textLabel.text = albumData.name;
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		
		return cell;
	}
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
		}
		
		PiwigoAlbumData *albumData = [[CategoriesData sharedInstance] getCategoryById:self.categoryId];
		
		cell.textLabel.text = albumData.name;
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		
		return cell;
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	PiwigoAlbumData *albumData;
	
	if(indexPath.section == 1)
	{
		albumData = [[CategoriesData sharedInstance].allCategories objectAtIndex:indexPath.row];
	}
	else
	{
		albumData = [[CategoriesData sharedInstance] getCategoryById:self.categoryId];
	}
	
	[UIAlertView showWithTitle:NSLocalizedString(@"categoryImageSet_title", @"Set Image Represenative")
					   message:[NSString stringWithFormat:NSLocalizedString(@"categoryImageSet_message", @"Are you sure you want to set this image for the album \"%@\"?"), albumData.name]
			 cancelButtonTitle:NSLocalizedString(@"alertNoButton", @"No")
			 otherButtonTitles:@[NSLocalizedString(@"alertYesButton", @"Yes")]
					  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
						  if(buttonIndex == 1)
						  {
							  [self setRepresenativeForCategoryId:albumData.albumId];
						  }
					  }];
	
}

-(void)setRepresenativeForCategoryId:(NSInteger)categoryId
{
	[AlbumService setCategoryRepresentativeForCategory:categoryId
											forImageId:self.imageId
										  OnCompletion:^(AFHTTPRequestOperation *operation, BOOL setSuccessfully) {
											  if(setSuccessfully)
											  {
												  PiwigoAlbumData *category = [[CategoriesData sharedInstance] getCategoryById:categoryId];
												  category.albumThumbnailId = self.imageId;
												  PiwigoImageData *imgData = [[CategoriesData sharedInstance] getImageForCategory:categoryId andId:[NSString stringWithFormat:@"%@", @(self.imageId)]];
												  category.albumThumbnailUrl = imgData.thumbPath;

												  UIImageView *dummyView = [UIImageView new];
												  [dummyView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[imgData.mediumPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
													  category.categoryImage = image;
													  [[NSNotificationCenter defaultCenter] postNotificationName:kPiwigoNotificationCategoryImageUpdated object:nil];
												  } failure:nil];
												  
												  
												  [UIAlertView showWithTitle:NSLocalizedString(@"categoryImageSetSuccess_title", @"Image Set Successful")
																	 message:NSLocalizedString(@"categoryImageSetSuccess_message", @"The image was set successfully for the album image")
														   cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
														   otherButtonTitles:nil
																	tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
																		[self.navigationController popViewControllerAnimated:YES];
																	}];
											  }
											  else
											  {
												  [self showSetRepresenativeError:nil];
											  }
										  } onFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
											  [self showSetRepresenativeError:[error localizedDescription]];
										  }];
}
-(void)showSetRepresenativeError:(NSString*)message
{
	NSString *bodyMessage = NSLocalizedString(@"categoryImageSetError_message", @"Failed to set the album image");
	if(message)
	{
		bodyMessage = [NSString stringWithFormat:@"%@\n%@", bodyMessage, message];
	}
	[UIAlertView showWithTitle:NSLocalizedString(@"categoryImageSetError_title", @"Image Set Error")
					   message:bodyMessage
			 cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
			 otherButtonTitles:nil
					  tapBlock:nil];
}

@end
