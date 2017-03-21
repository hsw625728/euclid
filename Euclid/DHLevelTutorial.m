//
//  DHLevel1.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelTutorial.h"
#import "DHLevelViewController.h"

@interface DHLevelTutorial () {
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHPoint* _point;
    Message* message1;
    Message* message3;
    BOOL _noRepeat, _levelComplete;
    NSUInteger _currentStep;
}
@end

@implementation DHLevelTutorial

- (NSString*)levelDescription
{
    return (@"");
}

- (NSString *)additionalCompletionMessage
{
    //return @"Well done! You are now ready to begin with Level 1.";
    return @"好样的! 你现在已经做好面对第一个挑战的准备了。";
}

- (DHToolsAvailable)availableTools
{
    return (0);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        _pointA = [[DHPoint alloc] initWithPositionX:310 andY:450];
        _pointB = [[DHPoint alloc] initWithPositionX:460 andY:450];
    } else {
        _pointA = [[DHPoint alloc] initWithPositionX:430 andY:250];
        _pointB = [[DHPoint alloc] initWithPositionX:590 andY:250];
    }
    
    _noRepeat = NO;
    _levelComplete = NO;
    _currentStep = 1;
    
    [self.geometryView.layer setValue:[NSNumber numberWithFloat:0.0] forKeyPath:@"opacity"];
    [geometricObjects addObject:_pointA];
    [geometricObjects addObject:_pointB];
    
    message1 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(0,0)];
    message3 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(0,0)];
}

- (void)positionMessagesForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [message1 position:CGPointMake(150,260)];
        [message3 position:CGPointMake(20,810)];
    } else {
        [message1 position:CGPointMake(300,50)];
        [message3 position:CGPointMake(20,554)];
    }
    if (self.iPhoneVersion) {
        [message1 position:CGPointMake(5,50)];
        [message3 position:CGPointMake(5,530)];
    }
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    if (_levelComplete){
        [self fadeOut:message3 withDuration:1.0];
    }
    return _levelComplete;
}

- (void)tutorial:(NSMutableArray*)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstruction and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolControl and:(BOOL)update
{
    if (_noRepeat && update) return;
    
    BOOL segmentAB = NO;
    BOOL circleAB = NO;
    BOOL circleBA = NO;
    BOOL lineAB = NO;
    BOOL intersection = NO;
    BOOL moved = NO;
    
    DHLineSegment* sAB = [[DHLineSegment alloc]initWithStart:_pointA andEnd:_pointB];
    DHLine *lAB = [[DHLine alloc]initWithStart:_pointA andEnd:_pointB];
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_pointA andPointOnRadius:_pointB];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_pointA];
    
    for (id object in geometricObjects) {
        if (EqualLineSegments(sAB, object)) segmentAB =YES;
        if (EqualCircles(cAB,object)) circleAB = YES;
        if (EqualCircles(cBA,object)) circleBA = YES;
        if ([object class] == [DHIntersectionPointCircleCircle class] ||
            [object class] == [DHIntersectionPointLineCircle class] ||
            [object class] == [DHIntersectionPointLineLine class]) {
            intersection = YES;
            DHPoint* p = object;
            _point = [[DHPoint alloc] initWithPositionX:p.position.x andY:p.position.y];
        }
        if (EqualLines(lAB,object)) lineAB = YES;
        if (_pointA.position.x != 310){
            moved = YES;
            _point = _pointA;
        }
        else if(_pointB.position.x != 460) {
            moved = YES;
            _point = _pointB;
        }
    }
    if (_currentStep == 1) {
        toolInstruction.alpha = 0;
        message1.alpha = 0;
        message3.alpha = 0;
        
        _currentStep = 2;
        //[message1 text:@"Points are the most fundamental objects in this game."];
        [message1 text:@"点是这一系列挑战中最基础的对象。"];
        
        [view addSubview:message1];
        [view addSubview:message3];
        
        [self afterDelay:1.0 :^{
            [self fadeIn:message1 withDuration:1.0];
        }];
        
        DHPoint* pointA = [[DHPoint alloc]initWithPosition:_pointA.position];
        DHPoint* pointB = [[DHPoint alloc]initWithPosition:_pointB.position];
        DHGeometryView* tempView = [[DHGeometryView alloc]initWithObjects:@[pointA,pointB]
                                                                  supView:geometryView addTo:view];
        [self afterDelay:3.0 :^{
            [self fadeIn:tempView withDuration:1.0];
        }];
        [self afterDelay:5.0 :^{
            //[message1 appendLine:@"They are labeled with capital letters." withDuration:1.0];
            [message1 appendLine:@"通常点都用大写字母来标记。" withDuration:1.0];
        }];
        [self afterDelay:7.0 :^{
            [self fadeIn:geometryView withDuration:1.0];
            [self fadeOut:tempView withDuration:1.0];
        }];
        [self afterDelay:9.0 :^{
            //[message3 text:@"Other objects can be constructed from points using the toolbar below."];
            [message3 text:@"其他的对象都可以通过下面工具栏用点来进行构造。"];
            [self fadeIn:message3 withDuration:1.0];
        }];
        [self afterDelay:11.0 :^{
            [self slideInToolbar];
        }];
        [self afterDelay:13.0 :^{
            //[message3 appendLine:@"Let's start by constructing a line segment. Tap the tool to select it."
            [message3 appendLine:@"让我们从构建一个线段开始。首先请点击工具栏进行选择。"
                    withDuration:1.0];
            
            [self enableToolAtIndex:2];
        }];
    }
    else if (_currentStep == 2 && toolControl.selectedSegmentIndex == 2 ) {
        _currentStep = 3;
        [self fadeOut:message1 withDuration:1.0];
        //[message1 text:@"Try to construct a line segment that connects point A and B."];
        [message1 text:@"尝试构建一条连接点A和B的线段。"];
        [self fadeInViews:@[message1, toolInstruction] withDuration:1.0];
        [self fadeOut:message3 withDuration:1.0];
    }
    else if (_currentStep == 3 && segmentAB) {
        _currentStep = 4;
        [self showWellDoneForObject:sAB];
        
        [self fadeOut:message1 withDuration:1.0];
        [self disableToolAtIndex:2];
        
        [self afterDelay:1.0 :^{
            [self fadeOut:toolInstruction withDuration:1.0];
            
            //[message3 text: @"Points can also be used to construct a circle."];
            [message3 text: @"点也可以用来构建圆。"];
            
            [self afterDelay:1.0 :^{
                [self fadeIn:message3 withDuration:1.0];
            }];
            [self afterDelay:3.0 :^{
                //[message3 appendLine:@"Tap the circle tool to select it." withDuration:1.0];
                [message3 appendLine:@"请点击工具栏中的圆工具。" withDuration:1.0];
            }];
            [self afterDelay:4.0 :^{
                [self enableToolAtIndex:4];
            }];
        }];
    }
    else if (_currentStep == 4 && toolControl.selectedSegmentIndex == 4) {
        _currentStep = 5;
        //[message1 text:@"Try to construct a circle with center A and radius AB."];
        [message1 text:@"请尝试构造一个以A为圆心，以AB为半径的圆。"];
        [self fadeOut:message3 withDuration:1.0];
        [self fadeInViews:@[toolInstruction, message1] withDuration:1.0];
    }
    else if (_currentStep == 5 && circleAB) {
        _currentStep = 6;
        [self showWellDoneForObject:cAB];
        
        [self fadeOut:message1 withDuration:1.0];
        [self afterDelay:1.0 :^{
            //[message1 text: @"Now, let's make a circle with center B (!) and radius AB."];
            [message1 text: @"现在，我们来构造一个以B为圆心，以AB为半径的圆。"];
            [self fadeIn:message1 withDuration:1.0];
        }];
    }
    else if (_currentStep == 6 && circleBA) {
        _currentStep = 7;
        
        [self fadeOut:message1 withDuration:1.0];
        [self showWellDoneForObject:cBA];
        
        [self afterDelay:1.0 :^{
            [self fadeOut:toolInstruction withDuration:1.0];
            //[message3 text:@"Sometimes it is useful to extend a segment using the line tool."];
            [message3 text:@"有时，使用直线工具来扩展段是很有用的技巧。"];
            [self fadeIn:message3 withDuration:1.0];
            [self disableToolAtIndex:4];
        }];
        [self afterDelay:3.0 :^{
            //[message3 appendLine:@"Tap the tool to select it." withDuration:1.0];
            [message3 appendLine:@"点击工具栏选择直线工具。" withDuration:1.0];
            [self enableToolAtIndex:3];
        }];
    }
    else if (_currentStep == 7 && toolControl.selectedSegmentIndex == 3) {
        _currentStep = 8;
        //[message1 text:@"Try to construct a line using the points A and B."];
        [message1 text:@"请尝试以点A和点B创建一条直线。"];
        [self fadeOut:message3 withDuration:1.0];
        [self fadeInViews:@[toolInstruction, message1] withDuration:1.0];
    }
    else if (_currentStep == 8 && lineAB) {
        _currentStep = 9;
        
        [self fadeOut:message1 withDuration:1.0];
        [self fadeOut:toolInstruction withDuration:1.0];
        [self showWellDoneForObject:lAB];
        
        [self afterDelay:1.0 :^{
            //[message3 text:@"If lines or circles intersect we can create a point at the intersection."];
            [message3 text:@"如果直线或者圆相交了，我们可以在交点的位置创建一个新的点。"];
            [self fadeIn:message3 withDuration:1.0];
            [self disableToolAtIndex:3];
        }];
        [self afterDelay:3.0 :^{
            //[message3 appendLine:@"Tap the intersect tool to select it." withDuration:1.0];
            [message3 appendLine:@"请选择工具栏中的交点工具。" withDuration:1.0];
            [self enableToolAtIndex:1];
        }];
    }
    else if (_currentStep == 9 && toolControl.selectedSegmentIndex == 1) {
        _currentStep = 10;
        [self fadeOut:message3 withDuration:1.0];
        //[message1 text:@"Construct a point at an intersection."];
        [message1 text:@"在交点的位置创建一个新的点。"];
        [self fadeIn:message1 withDuration:1.0];
        [self fadeIn:toolInstruction withDuration:1.0];
    }
    else if (_currentStep == 10 && intersection) {
        _currentStep = 11;
        [self fadeOut:message1 withDuration:1.0];
        [self showWellDoneForObject:_point];
        
        [self afterDelay:2.0 :^{
            //[message3 text:@"Note that the intersection point is black. Black points are unmovable and precise."];
            [message3 text:@"请注意交点是黑色的，黑色的点是精确的并且是不可移动的。"];
            [self fadeIn:message3 withDuration:1.0];
            [self fadeOut:toolInstruction withDuration:1.0];
            [self disableToolAtIndex:1];
        }];
        
        [self afterDelay:4.0 :^{
            //[message3 appendLine:@"Grey points are not placed precisely on an intersection and are movable."
            [message3 appendLine:@"灰色的点不是精确地放置在交叉点上并且是可移动的。"
                    withDuration:1.0];
        }];

        [self afterDelay:6.0 :^{
            //[message3 appendLine:@"Try to move a grey point using the point tool."
            [message3 appendLine:@"请尝试使用点工具来拖动一个灰色的点。"
                    withDuration:1.0];
            [self enableToolAtIndex:0];
        }];
    }
    else if (_currentStep == 11 && toolControl.selectedSegmentIndex == 0 ) {
        _currentStep = 12;
        
        [self fadeOut:message3 withDuration:1.0];
        [self fadeIn:toolInstruction withDuration:1.0];
        //[message1 text:@"Move one of the grey points."];
        [message1 text:@"移动一个灰色的点。"];
        [self fadeIn:message1 withDuration:1.0];
    }
    else if (_currentStep == 12 && moved) {
        _currentStep = 13;
        _noRepeat = YES;
        [self fadeOut:message1 withDuration:1.0];
        [self showWellDoneForObject:_point];
        
        [self afterDelay:2.0 :^{
            //[message3 text: @"These are the 5 primitive tools you will start with in Level 1."];
            [message3 text: @"这些是您将在挑战1中开始使用的5个原始工具。"];
            [self fadeIn:message3 withDuration:1.0];
            
            [self enableToolAtIndex:0];
            [self enableToolAtIndex:1];
            [self enableToolAtIndex:2];
            [self enableToolAtIndex:3];
            [self enableToolAtIndex:4];
        }];

        [self afterDelay:4.0 :^{
            //[message3 appendLine:@"To unlock the other tools, you need to complete more levels!"
            [message3 appendLine:@"想解锁其他更多的工具，你需要完成更多的挑战！"
                    withDuration:1.0];
        }];

        [self afterDelay:6.0 :^{
            //[message3 appendLine:@"Construct a new object with any of the 5 available tools to complete the tutorial."
            [message3 appendLine:@"使用5种可用工具中的任何一种构建新对象以完成新手教学。"
                    withDuration:1.0];
            _levelComplete=YES;
        }];
    }
}

- (void)enableToolAtIndex:(NSUInteger)index
{
    [UIView
     animateWithDuration:1.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
         [self.levelViewController.toolControl setEnabled:YES forSegmentAtIndex:index];
     } completion:^(BOOL finished) {}];
}
- (void)disableToolAtIndex:(NSUInteger)index
{
    [UIView
     animateWithDuration:1.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
         [self.levelViewController.toolControl setEnabled:NO forSegmentAtIndex:index];
     } completion:^(BOOL finished) {}];
}

- (void)showWellDoneForObject:(id)object
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    CGPoint messagePos = [geometryView.geoViewTransform geoToView:Position(object)];
    //[self.levelViewController showTemporaryMessage:@"Well done!" atPoint:messagePos
    [self.levelViewController showTemporaryMessage:@"太棒了!" atPoint:messagePos
                                         withColor:[UIColor darkGrayColor]];
    
}

@end

