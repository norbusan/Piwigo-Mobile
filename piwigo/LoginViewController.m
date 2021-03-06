//
//  LoginViewController.m
//  piwigo
//
//  Created by Spencer Baker on 1/17/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//

#import "LoginViewController.h"
#import "PiwigoButton.h"
#import "PiwigoTextField.h"
#import "ServerField.h"
#import "KeychainAccess.h"
#import "Model.h"
#import "SessionService.h"
#import "AppDelegate.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *piwigoLogo;
@property (nonatomic, strong) ServerField *serverTextField;
@property (nonatomic, strong) PiwigoTextField *userTextField;
@property (nonatomic, strong) PiwigoTextField *passwordTextField;
@property (nonatomic, strong) PiwigoButton *loginButton;

@property (nonatomic, strong) NSLayoutConstraint *logoTopConstraint;
@property (nonatomic, assign) NSInteger topConstraintAmount;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UILabel *loggingInLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation LoginViewController

-(instancetype)init
{
	self = [super init];
	if(self)
	{
		self.view.backgroundColor = [UIColor piwigoGray];
		
		self.piwigoLogo = [UIImageView new];
		self.piwigoLogo.translatesAutoresizingMaskIntoConstraints = NO;
		self.piwigoLogo.image = [UIImage imageNamed:@"piwigoLogo"];
		self.piwigoLogo.contentMode = UIViewContentModeScaleAspectFit;
		[self.view addSubview:self.piwigoLogo];
		
		self.serverTextField = [ServerField new];
		self.serverTextField.translatesAutoresizingMaskIntoConstraints = NO;
		self.serverTextField.textField.placeholder = NSLocalizedString(@"login_serverPlaceholder", @"Server");
		self.serverTextField.textField.text = [Model sharedInstance].serverName;
		self.serverTextField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.serverTextField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.serverTextField.textField.keyboardType = UIKeyboardTypeURL;
		self.serverTextField.textField.returnKeyType = UIReturnKeyNext;
		self.serverTextField.textField.delegate = self;
		[self.view addSubview:self.serverTextField];
				
		self.userTextField = [PiwigoTextField new];
		self.userTextField.translatesAutoresizingMaskIntoConstraints = NO;
		self.userTextField.placeholder = NSLocalizedString(@"login_userPlaceholder", @"Username (optional)");
		self.userTextField.text = [KeychainAccess getLoginUser];
		self.userTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.userTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.userTextField.returnKeyType = UIReturnKeyNext;
		self.userTextField.delegate = self;
		[self.view addSubview:self.userTextField];
		
		self.passwordTextField = [PiwigoTextField new];
		self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
		self.passwordTextField.placeholder = NSLocalizedString(@"login_passwordPlaceholder", @"Password (optional)");
		self.passwordTextField.secureTextEntry = YES;
		self.passwordTextField.text = [KeychainAccess getLoginPassword];
		self.passwordTextField.returnKeyType = UIReturnKeyGo;
		self.passwordTextField.delegate = self;
		[self.view addSubview:self.passwordTextField];
		
		self.loginButton = [PiwigoButton new];
		self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
		[self.loginButton setTitle:NSLocalizedString(@"login", @"Login") forState:UIControlStateNormal];
		[self.loginButton addTarget:self action:@selector(performLogin) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.loginButton];
		
		[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
		
		self.loadingView = [UIView new];
		self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
		self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
		self.loadingView.hidden = YES;
		[self.view addSubview:self.loadingView];
		
		self.loggingInLabel = [UILabel new];
		self.loggingInLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.loggingInLabel.text = NSLocalizedString(@"login_loggingIn", @"Logging In...");
		self.loggingInLabel.font = [UIFont piwigoFontNormal];
		self.loggingInLabel.textColor = [UIColor whiteColor];
		[self.loadingView addSubview:self.loggingInLabel];
		
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
		[self.loadingView addSubview:self.spinner];
		
		[self setupAutoLayout];
	}
	return self;
}

-(void)setupAutoLayout
{
	NSInteger textFeildHeight = 64;
	
	NSDictionary *views = @{
							@"logo" : self.piwigoLogo,
							@"login" : self.loginButton,
							@"server" : self.serverTextField,
							@"user" : self.userTextField,
							@"password" : self.passwordTextField
							};
	NSDictionary *metrics = @{
							  @"imageSide" : @25,
							  @"imageTop" : @40,
							  @"imageBottom" : @20,
							  @"side" : @35
							  };
	self.topConstraintAmount = 40;
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logo]-imageBottom-[server]-[user]-[password]-[login]"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	self.logoTopConstraint = [NSLayoutConstraint constraintViewFromTop:self.piwigoLogo amount:self.topConstraintAmount];
	[self.view addConstraint:self.logoTopConstraint];
	
	[self.piwigoLogo addConstraint:[NSLayoutConstraint constraintView:self.piwigoLogo toHeight:textFeildHeight + 36]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-imageSide-[logo]-imageSide-|"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	[self.serverTextField addConstraint:[NSLayoutConstraint constraintView:self.serverTextField toHeight:textFeildHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[server]-side-|"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	[self.userTextField addConstraint:[NSLayoutConstraint constraintView:self.userTextField toHeight:textFeildHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[user]-side-|"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	[self.passwordTextField addConstraint:[NSLayoutConstraint constraintView:self.passwordTextField toHeight:textFeildHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[password]-side-|"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	[self.loginButton addConstraint:[NSLayoutConstraint constraintView:self.loginButton toHeight:textFeildHeight]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-side-[login]-side-|"
																	  options:kNilOptions
																	  metrics:metrics
																		views:views]];
	
	
	[self.view addConstraints:[NSLayoutConstraint constraintFillSize:self.loadingView]];
	[self.loadingView addConstraints:[NSLayoutConstraint constraintCenterView:self.spinner]];
	[self.loadingView addConstraint:[NSLayoutConstraint constraintCenterVerticalView:self.loggingInLabel]];
	[self.loadingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-[spinner]"
																			 options:kNilOptions
																			 metrics:nil
																			   views:@{@"spinner" : self.spinner,
																					   @"label" : self.loggingInLabel}]];
}

-(void)moveTextFieldsBy:(NSInteger)amount
{
	self.logoTopConstraint.constant = amount;
	[UIView animateWithDuration:0.3 animations:^{
		[self.view layoutIfNeeded];
	}];
}

-(void)dismissKeyboard
{
	[self moveTextFieldsBy:self.topConstraintAmount];
	[self.view endEditing:YES];
}

-(void)performLogin
{
	[self.view endEditing:YES];
	[self showLoading];
	
	if(self.serverTextField.textField.text.length <= 0)
	{
		[UIAlertView showWithTitle:NSLocalizedString(@"loginEmptyServer_title", @"Enter a Web Address")
						   message:NSLocalizedString(@"loginEmptyServer_message", @"Please enter a Piwigo web address in order to proceed")
				 cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
				 otherButtonTitles:nil
						  tapBlock:nil];
		
		[self hideLoading];
		return;
	}
	
	NSString *cleanServerString = [self cleanServerString:self.serverTextField.textField.text];
	self.serverTextField.textField.text = cleanServerString;
	
	[Model sharedInstance].serverName = cleanServerString;
	[Model sharedInstance].serverProtocol = [self.serverTextField getProtocolString];
	[[Model sharedInstance] saveToDisk];

	if(self.userTextField.text.length > 0)
	{
		[SessionService performLoginWithUser:self.userTextField.text
								  andPassword:self.passwordTextField.text
								 onCompletion:^(BOOL result, id response) {
									 if(result)
									 {
										 [self getSessionStatus];
									 }
									 else
									 {
										 [self hideLoading];
										 [self showLoginFail];
									 }
								 } onFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
									 [self hideLoading];

									 NSString *extraErrorString = @"";
									 if(error.code == -1012)
									 {
										 extraErrorString = [NSString stringWithFormat:@"\n%@", NSLocalizedString(@"loginError_protocol", @"This might be because your server doesn't support https")];
									 }
									 
									 [UIAlertView showWithTitle:NSLocalizedString(@"internetErrorGeneral_title", @"Connection Error")
														message:[NSString stringWithFormat:@"%@%@", [error localizedDescription], extraErrorString]
											  cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
											  otherButtonTitles:nil
													   tapBlock:nil];
								 }];
	}
	else
	{
		[self getSessionStatus];
		[KeychainAccess resetKeychain];
	}
}

-(NSString*)cleanServerString:(NSString*)serverString
{
	NSString *server = serverString;
	
	NSRange httpRange = [server rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
	if(httpRange.location == 0)
	{
		server = [server substringFromIndex:7];
	}
	
	NSRange httpsRange = [server rangeOfString:@"https://" options:NSCaseInsensitiveSearch];
	if(httpsRange.location == 0)
	{
		server = [server substringFromIndex:8];
	}
	
	NSRange wwwRange = [server rangeOfString:@"www." options:NSCaseInsensitiveSearch];
	if(wwwRange.location == 0)
	{
		server = [server substringFromIndex:4];
	}
	
	return server;
}

-(void)getSessionStatus
{
	[SessionService getStatusOnCompletion:^(NSDictionary *responseObject) {
		[self hideLoading];
		if(responseObject)
		{
			if([@"2.7" compare:[Model sharedInstance].version options:NSNumericSearch] != NSOrderedAscending)
			{	// they need to update
				[UIAlertView showWithTitle:NSLocalizedString(@"serverVersionNotCompatable_title", @"Server Incompatable")
								   message:[NSString stringWithFormat:NSLocalizedString(@"serverVersionNotCompatable_message", @"Your server version is %@. Piwigo Mobile only supports a version of at least 2.7. Please update your server to use Piwigo Mobile\nDo you still want to continue?"), [Model sharedInstance].version]
						 cancelButtonTitle:NSLocalizedString(@"alertNoButton", @"No")
						 otherButtonTitles:@[NSLocalizedString(@"alertYesButton", @"Yes")]
								  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
									  if(buttonIndex == 1)
									  {	// proceed at their own risk
										  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
										  [appDelegate loadNavigation];
									  }
								  }];
			}
			else
			{	// their version is okay
				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate loadNavigation];
			}
		}
		else
		{
			UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sessionStatusError_title", @"Authentication Fail")
																message:NSLocalizedString(@"sessionStatusError_message", @"Failed to authenticate with server.\nTry logging in again.")
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
													  otherButtonTitles:nil];
			[failAlert show];
		}
	} onFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self hideLoading];
	}];
}

-(void)showLoading
{
	self.loadingView.hidden = NO;
	[self.spinner startAnimating];
}
-(void)hideLoading
{
	[self.spinner stopAnimating];
	self.loadingView.hidden = YES;
}

-(void)showLoginFail
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginError_title", @"Login Fail")
													message:NSLocalizedString(@"loginError_message", @"The username and password don't match on the given server")
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"alertOkayButton", @"Okay")
										  otherButtonTitles:nil];
	[alert show];
}


#pragma mark -- UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField == self.serverTextField.textField) {
		[self.userTextField becomeFirstResponder];
	} else if (textField == self.userTextField) {
		[self.passwordTextField becomeFirstResponder];
	} else if (textField == self.passwordTextField) {
		if(self.view.frame.size.height > 320)
		{
			[self moveTextFieldsBy:self.topConstraintAmount];
		}
		[self performLogin];
	}
	return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(self.view.frame.size.height > 500) return;
	
	NSInteger amount = 0;
	if (textField == self.userTextField)
	{
		amount = -self.topConstraintAmount;
	}
	else if (textField == self.passwordTextField)
	{
		amount = -self.topConstraintAmount * 2;
	}
	
	[self moveTextFieldsBy:amount];
}

@end
