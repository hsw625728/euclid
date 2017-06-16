//
//  DHGameModeSelectionViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGameModeSelectionViewController.h"
#import "DHLevelViewController.h"
#import "DHLevelSelection2ViewController.h"
#import "DHLevelPlayground.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHGameModes.h"
#import "DHGameCenterManager.h"
#import "DHPopoverView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "PopMenu.h"
#import "UIColor+MLBUtilities.h"
#import "UIDevice+IdentifierAddition.h"

@interface DHGameModeSelectionViewController () <DHPopoverViewDelegate>
@property (strong, nonatomic) PopMenu *popMenu;
- (void)shareMeToYourFriends;
- (void)shareToWeixin;
- (void)shareToWeixinTimeline;
- (void)shareToQQ;
- (void)shareToWeibo;
- (void)shareToMail;
- (void)shareToSMS;
@end

@implementation DHGameModeSelectionViewController {
    BOOL _iPhoneVersion;
    DHPopoverView* _popoverMenu;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        _iPhoneVersion = YES;
    }
    [self.gameMode1View setTouchActionWithTarget:self andAction:@selector(loadTutorial)];
    [self.gameMode2View setTouchActionWithTarget:self andAction:@selector(selectGameMode1)];
    [self.gameMode3View setTouchActionWithTarget:self andAction:@selector(selectGameMode2)];
    [self.gameMode4View setTouchActionWithTarget:self andAction:@selector(selectGameMode3)];
    [self.gameMode5View setTouchActionWithTarget:self andAction:@selector(selectGameMode4)];
    [self.gameMode6View setTouchActionWithTarget:self andAction:@selector(loadPlayground)];
    
    self.gameMode2View.showPercentComplete = YES;
    self.gameMode3View.showPercentComplete = YES;
    self.gameMode4View.showPercentComplete = YES;
    self.gameMode5View.showPercentComplete = YES;
    
    /*
    self.gameMode1View.title = @"Tutorial";
    self.gameMode2View.title = @"The Elements";
    self.gameMode3View.title = @"Perfectionist";
    self.gameMode4View.title = @"Ancient Greece";
    self.gameMode5View.title = @"Hardcore";
    self.gameMode6View.title = @"Playground";
    
    self.gameMode2View.difficultyDescription = @"Normal";
    self.gameMode3View.difficultyDescription = @"Hard";
    self.gameMode4View.difficultyDescription = @"Harder";
    self.gameMode5View.difficultyDescription = @"Insane";
    
    self.gameMode1View.gameModeDescription = @"Learn the basics";
    self.gameMode2View.gameModeDescription = @"Complete geometric challenges and unlock new tools";
    self.gameMode3View.gameModeDescription = @"Finish the levels using a minimum number of moves";
    self.gameMode4View.gameModeDescription = @"Take on the levels using only the primitive tools";
    self.gameMode5View.gameModeDescription = @"Limited to primitive tools and must use minimum number of moves";
    self.gameMode6View.gameModeDescription = @"Simply enjoy using all the available tools freely";
    */
    self.gameMode1View.title = @"新手教学";
    self.gameMode2View.title = @"基本元素";
    self.gameMode3View.title = @"完美主义";
    self.gameMode4View.title = @"古希腊人";
    self.gameMode5View.title = @"几何大师";
    self.gameMode6View.title = @"自由演练";
    
    self.gameMode2View.difficultyDescription = @"一般";
    self.gameMode3View.difficultyDescription = @"难";
    self.gameMode4View.difficultyDescription = @"更难";
    self.gameMode5View.difficultyDescription = @"极难";
    
    self.gameMode1View.gameModeDescription = @"学习最基本的操作方法";
    self.gameMode2View.gameModeDescription = @"完成几何挑战同时解锁新工具";
    self.gameMode3View.gameModeDescription = @"用最少的步骤完成指定挑战目标";
    self.gameMode4View.gameModeDescription = @"使用最原始的工具完成指定挑战目标";
    self.gameMode5View.gameModeDescription = @"使用最原始的工具并且用最少的步骤完成指定挑战目标";
    self.gameMode6View.gameModeDescription = @"使用所有可用的工具自由发挥想象力";
    
    if (_iPhoneVersion) {
        //self.title = @"Euclid: The Game";
        self.title = @"几何大师";
    }
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showPopoverMenu:)];
    self.navigationItem.rightBarButtonItem = menuButton;
    self.navigationItem.leftBarButtonItem = nil;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProgressData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowLevelSelection2"]) {
        DHLevelSelection2ViewController* vc = [segue destinationViewController];
        vc.currentGameMode = [sender unsignedIntegerValue];
    }
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self updateViewConstraintsToOrientation:self.interfaceOrientation];
}

- (void)updateViewConstraintsToOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    [super updateViewConstraints];
    
    if (_iPhoneVersion) {
        [self updateViewConstraintsToiPhone];
        return;
    }
    
    if (!self.layoutConstraintsLandscape) {
        self.layoutConstraintsLandscape = [[NSMutableArray alloc] initWithCapacity:10];
        
        // First game mode button
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop
                                     multiplier:1 constant:80]];
        
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view attribute:NSLayoutAttributeRight
                                     multiplier:1 constant:-30]];
        
        // Logo
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeBottom
                                     multiplier:1 constant:10]];
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1 constant:self.logoImageView.frame.size.width]];
    }
    
    [self.view removeConstraints:self.layoutConstraintsLandscape];
    [self.view removeConstraints:self.layoutConstraintsPortrait];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self.view addConstraints:self.layoutConstraintsPortrait];
        self.selectGameModelLabel.hidden = NO;
    } else {
        [self.view addConstraints:self.layoutConstraintsLandscape];
        self.selectGameModelLabel.hidden = YES;
    }
}

- (void)updateViewConstraintsToiPhone
{
    if (!self.layoutConstraintsiPhone) {
        self.logoImageTopConstraint.constant = 5;
        self.logoImageHeightConstraint.constant = 40;
        self.logoImageLeadingConstraint.constant = 8;
        self.logoImageWidthConstraint.constant = 40;
        self.selectGameModelLabel.hidden = NO;
        self.selectGameModelLabel.font = [UIFont systemFontOfSize:12];
        
        self.gameMode1ViewWidthConstraint.constant = 310;
        self.gameMode1ViewHeightConstraint.constant = 60;
        
        CGFloat buttonSpacing = 8;
        CGFloat labelSpacing = 5;
        CGFloat topSpacing = 70;

        if ([[UIScreen mainScreen] bounds].size.height > 500) {
            buttonSpacing = 15;
            labelSpacing = 10;
            topSpacing = 90;
        }
        
        self.selectGameModeLabelDistanceConstraint.constant = labelSpacing;
        for (NSLayoutConstraint* constraint in self.gameModeViewDistanceConstraints) {
            constraint.constant = buttonSpacing;
        }
        
        self.layoutConstraintsiPhone = [[NSMutableArray alloc] initWithCapacity:10];
        self.logoImageView.hidden = YES;
        self.logoLabel.hidden = YES;
        self.logoSubtitleLabel.hidden = YES;
        
        // First game mode button
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop
                                     multiplier:1 constant:topSpacing]];
        
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        
        // Logo
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeCenterY
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeRight
                                     multiplier:1 constant:10]];
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1 constant:self.logoImageView.frame.size.width]];
        
        [self.view removeConstraints:self.layoutConstraintsPortrait];
        [self.view addConstraints:self.layoutConstraintsiPhone];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateViewConstraintsToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[self updateViewConstraints];
}

#pragma mark - Select game modes
- (void)selectGameMode1
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormal]];
}
- (void)selectGameMode2
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormalMinimumMoves]];
}
- (void)selectGameMode3
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModePrimitiveOnly]];
}
- (void)selectGameMode4
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModePrimitiveOnlyMinimumMoves]];
}
- (void)loadPlayground
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    vc.currentLevel = [[DHLevelPlayground alloc] init];
    vc.levelArray = nil;
    vc.levelIndex = 0;
    //vc.title = @"Playground";
    vc.title = @"自由演练";
    vc.currentGameMode = kDHGameModePlayground;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)loadTutorial
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    vc.currentLevel = [[DHLevelTutorial alloc] init];
    vc.levelArray = nil;
    vc.levelIndex = NSUIntegerMax;
    //vc.title = @"Tutorial";
    vc.title = @"新手教学";
    vc.currentGameMode = kDHGameModeTutorial;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Other
- (void)loadProgressData
{
    NSMutableArray* levels = [[NSMutableArray alloc] initWithCapacity:30];
    FillLevelArray(levels);
    
    NSUInteger levelsCompleteNormal = 0;
    NSUInteger levelsCompleteMinimumMoves = 0;
    NSUInteger levelsCompletePrimitiveOnly = 0;
    NSUInteger levelsCompletePrimitiveOnlyMinimumMoves = 0;
    
    levelsCompleteNormal = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModeNormal];
    levelsCompleteMinimumMoves = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModeNormalMinimumMoves];
    levelsCompletePrimitiveOnly = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModePrimitiveOnly];
    levelsCompletePrimitiveOnlyMinimumMoves = [DHLevelResults
                                               numberOfLevesCompletedForGameMode:kDHGameModePrimitiveOnlyMinimumMoves];
    
    self.gameMode2View.percentComplete = levelsCompleteNormal*1.0/levels.count;
    self.gameMode3View.percentComplete = levelsCompleteMinimumMoves*1.0/levels.count;
    self.gameMode4View.percentComplete = levelsCompletePrimitiveOnly*1.0/levels.count;
    self.gameMode5View.percentComplete = levelsCompletePrimitiveOnlyMinimumMoves*1.0/levels.count;
    
    // Update achievements here if they were not awarded earlier
    if (self.gameMode2View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormal_1_25 percentComplete:100];
    }
    if (self.gameMode3View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormalMinimumMoves_1_25 percentComplete:100];
    }
    if (self.gameMode4View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnly_1_25 percentComplete:100];
    }
    if (self.gameMode5View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnlyMinimumMoves_1_25 percentComplete:100];
    }
}

- (IBAction)showLeaderboards:(id)sender
{
    [[DHGameCenterManager sharedInstance] showLeaderboard];
}

- (IBAction)closeSettings:(UIStoryboardSegue *)unwindSegue
{
    [self loadProgressData];
    if (!_iPhoneVersion) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)closeAboutView:(UIStoryboardSegue *)unwindSegue
{
    if (!_iPhoneVersion) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Popover menu methods
- (void)showPopoverMenu:(id)sender
{
    if(!_popoverMenu) {
        UIView* targetView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect originFrame = [[sender view] convertRect:[sender view].bounds toView:targetView];
        
        DHPopoverView *popOverView = [[DHPopoverView alloc] initWithOriginFrame:originFrame
                                                                       delegate:self
                                                               firstButtonTitle:nil];
        popOverView.width = 260;
        
        //[popOverView addButtonWithTitle:@"Settings"];
        //[popOverView addButtonWithTitle:@"Leaderboards & Achievements"];
        //[popOverView addButtonWithTitle:@"About"];
        [popOverView addButtonWithTitle:@"设置"];
        [popOverView addButtonWithTitle:@"排行榜 & 成就"];
        [popOverView addButtonWithTitle:@"关于"];
        [popOverView addButtonWithTitle:@"推广赚佣金"];
        [popOverView addButtonWithTitle:@"填写邀请人"];
        [popOverView show];
        
        _popoverMenu = popOverView;
    } else {
        [self hidePopoverMenu];
    }
}

-(void)hidePopoverMenu
{
    [_popoverMenu dismissWithAnimation:YES];
    _popoverMenu = nil;
}
- (void)closePopoverView:(DHPopoverView *)popoverView
{
    [self hidePopoverMenu];
}
- (void)popoverViewDidClose:(DHPopoverView *)popoverView
{
    
}
- (void)popoverView:(DHPopoverView *)popoverView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"showSettings" sender:nil];
            break;
        case 1:
            [self showLeaderboards:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showAboutView" sender:nil];
            break;
        case 3:
            [self shareMeToFriend];
            break;
        case 4:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入邀请人" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *txtName = [alert textFieldAtIndex:0];
            txtName.placeholder = @"填写邀请人的编码";
            [alert show];
        }
            break;
        default:
            break;
    }
    
    [self hidePopoverMenu];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //NSString *scoreStr = [NSString stringWithFormat:@"%i", [AppDelegate highScore]];
        //AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        
        NSString *post = [NSString stringWithFormat:@"deviceID=%@&fcode=%@&payed=%@",idfv, [txt text], @"no"];
        NSLog(@"POST_PARAM  | %@", post);
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://mengyoutu.cn/euclid/euclidrecord.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLResponse *response;
        NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
        NSLog(@"& API  | %@", theReply);
    }
    else
    {
        
    }
    
    
}
- (void)shareMeToFriend
{
    [self showPopMenuViewWithMenuSelectedBlock:^(MLBPopMenuType menuType) {
        
        //分享平台选择
        switch(menuType){
            case MLBPopMenuTypeWechatFrined:
                [self shareToWeixin];
                break;
            case MLBPopMenuTypeMoments:
                [self shareToWeixinTimeline];
                break;
            /*case MLBPopMenuTypeWeibo:
                [self shareToWeibo];
                break;*/
            case MLBPopMenuTypeQQ:
                [self shareToQQ];
                break;
            case MLBPopMenuTypeMail:
                [self shareToMail];
                break;
            case MLBPopMenuTypeSMS:
                [self shareToSMS];
                break;
            default:
                return;
                break;
        }
    }];
    
}

#define SHARE_URL_MENGYOUTU_FORMAT @"http://mengyoutu.cn/euclid/ecuref?usr_code=%@"
#define SHARE_TITLE @"[App推荐]史上最好玩的几何App"
#define SHARE_TEXT @"🍌欧几里得    🍎尺规作图\n🍊经典案例    🍉超酷操作\n➡️➡️点击进入下载页面⬅️⬅️"
#define THUMB_IMAGE @"EuclidLogo"
#define SHARE_IMAGE @"EuclidLogo"

#define SHARE_URL_MENGYOUTU [NSString stringWithFormat:SHARE_URL_MENGYOUTU_FORMAT, [[UIDevice currentDevice] uniqueDeviceIdentifier]]
- (void)shareToWeixin{
    //参数设定
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupWeChatParamsByText:SHARE_TEXT
                                       title:SHARE_TITLE
                                         url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                                  thumbImage:[UIImage imageNamed:THUMB_IMAGE]
                                       image:[UIImage imageNamed:SHARE_IMAGE]
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeApp
                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    //分享事件
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
}

- (void)shareToWeixinTimeline{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupWeChatParamsByText:SHARE_TEXT
                                       title:SHARE_TITLE
                                         url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                                  thumbImage:[UIImage imageNamed:THUMB_IMAGE]
                                       image:[UIImage imageNamed:SHARE_IMAGE]
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeApp
                          forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    //分享事件
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
}

- (void)shareToQQ{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupQQParamsByText:SHARE_TEXT
                                   title:SHARE_TITLE
                                     url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                              thumbImage:[UIImage imageNamed:THUMB_IMAGE]
                                   image:[UIImage imageNamed:SHARE_IMAGE]
                                    type:SSDKContentTypeWebPage
                      forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
    //分享事件
    [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
    
}

- (void)shareToWeibo{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupSinaWeiboShareParamsByText:SHARE_TEXT
                                               title:SHARE_TITLE
                                               image:[UIImage imageNamed:SHARE_IMAGE]
                                                 url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                                            latitude:0
                                           longitude:0
                                            objectID:nil
                                                type:SSDKContentTypeImage];
    
    
    //分享事件
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
}

- (void)shareToMail{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"🍌欧几里得    🍎尺规作图\n🍊经典案例    🍉超酷操作\n➡️➡️苹果商店搜索：几何大师⬅️⬅️"
                                     images:[UIImage imageNamed:SHARE_IMAGE]
                                        url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                                      title:SHARE_TITLE
                                       type:SSDKContentTypeAuto];
    
    //分享事件
    [ShareSDK share:SSDKPlatformTypeMail parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
}

- (void)shareToSMS{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"🍌欧几里得    🍎尺规作图\n🍊经典案例    🍉超酷操作\n➡️➡️苹果商店搜索：几何大师⬅️⬅️"
                                     images:[UIImage imageNamed:SHARE_IMAGE]
                                        url:[NSURL URLWithString:SHARE_URL_MENGYOUTU]
                                      title:SHARE_TITLE
                                       type:SSDKContentTypeAuto];
    
    //分享事件
    [ShareSDK share:SSDKPlatformTypeSMS parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         // 回调处理....
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                     message:@"🐰谢谢您的分享🐰"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 [alert show];
                 break;
             }
             default:
                 break;
         }
     }];
}

- (void)showPopMenuViewWithMenuSelectedBlock:(MenuSelectedBlock)block {
    if (!_popMenu) {
        
        NSArray *imgNames = @[@"more_wechat", @"more_moments",/* @"more_sina",*/ @"more_qq", @"more_link", @"more_collection"];
        NSArray *titles = @[@"微信", @"朋友圈", /*@"微博",*/ @"QQ", @"邮件", @"短信"];
        NSArray *colors = @[[UIColor colorWithRGBHex:0x70E08D],
                            [UIColor colorWithRGBHex:0x70E08D],
                            //[UIColor colorWithRGBHex:0xFF8467],
                            [UIColor colorWithRGBHex:0x49AFD6],
                            [UIColor colorWithRGBHex:0x659AD9],
                            [UIColor colorWithRGBHex:0xF6CC41]];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:imgNames.count];
        for (NSInteger i = 0; i < imgNames.count; i++) {
            /*
             BOOL test = [WXApi isWXAppInstalled];
             BOOL test1 = [WXApi isWXAppSupportApi];
             BOOL test2 = [WeiboSDK isWeiboAppInstalled];
             BOOL test3 = [WeiboSDK isCanSSOInWeiboApp];
             BOOL test4 = [WeiboSDK isCanShareInWeiboAPP];
             if (i == 1 || i == 0)
             {
             if (!([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]))
             {
             continue;
             }
             }
             
             if (i == 2)
             {
             if (!([WeiboSDK isWeiboAppInstalled] && [WeiboSDK isCanSSOInWeiboApp] && [WeiboSDK isCanShareInWeiboAPP]))
             {
             continue;
             }
             }*/
            MenuItem *item = [[MenuItem alloc] initWithTitle:titles[i] iconName:imgNames[i] glowColor:colors[i] index:i];
            [items addObject:item];
        }
        
        _popMenu = [[PopMenu alloc] initWithFrame:kKeyWindow.bounds items:items];
        _popMenu.menuAnimationType = kPopMenuAnimationTypeSina;
        _popMenu.perRowItemCount = 1;
        _popMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem) {
            if (block) {
                block((MLBPopMenuType)selectedItem.index);
            }
        };
    }
    
    [_popMenu showMenuAtView:kKeyWindow];
}
- (UIColor*)popOverTintColor
{
    return self.view.tintColor;
}

@end
