//
//  DHLevelCircleToTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelCircleToTangent.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelCircleToTangent () {
    DHLine* _givenLine;
    DHPoint* _pA;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelCircleToTangent

- (NSString*)levelDescription
{
    //return (@"Construct a circle that passes through A and is tangent to the line at B.");
    return (@"构建一个通过A的圆，并与给定直线相切在直线上的B点。");
}

- (NSString*)levelDescriptionExtra
{
    //return (@"Given a point A, a line, and a point B. Construct a circle that passes through A and is "
    //        @"tangent to the line at B. \n\nA circle and a line are tangent if they only touch at one point.");
    return (@"给定一个点A，一条直线和直线上的点B。\n构建一个通过A的圆，使之与给定直线相切在直线上的B点。\n\n一个圆和直线相切他们有且仅有一个公共点。");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 6;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    hint1_OK = NO;
    hint2_OK = NO;
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:140 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:350];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:400 andY:350];
    
    DHLine* lBC = [[DHLine alloc] initWithStart:pB andEnd:pC];
    
    [geometricObjects addObject:lBC];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _givenLine = lBC;
    _pA = pA;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.point = _givenLine.start;
    pl1.line = _givenLine;
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:_pA andEnd:_givenLine.start];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = lAB.start;
    mp.end = lAB.end;

    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.point = mp;
    pl2.line = lAB;

    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip andPointOnRadius:lAB.start];
    [objects insertObject:c atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pA.position;
    CGPoint pointB = _givenLine.start.position;
    
    _pA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _givenLine.start.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pA.position = pointA;
     _givenLine.start.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (id object in geometricObjects) {
        if ([[object class]  isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        DHCircle* circle = object;
        CGFloat radius = circle.radius;
        CGFloat distCA = DistanceBetweenPoints(_pA.position, circle.center.position);
        CGFloat distCB = DistanceBetweenPoints(_givenLine.start.position, circle.center.position);
        CGVector vCB = CGVectorNormalize(CGVectorBetweenPoints(_givenLine.start.position, circle.center.position));
        CGVector vLine = CGVectorNormalize(_givenLine.vector);
        CGFloat tangentAngle = CGVectorDotProduct(vCB, vLine);
        if (fabs(distCA - radius) < 0.01 && fabs(distCB-radius) < 0.01 && fabs(tangentAngle) < 0.01) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}

-(CGPoint)testObjectsForProgressHints:(NSArray *)objects {
    
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.point = _givenLine.start;
    pl1.line = _givenLine;
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:_pA andEnd:_givenLine.start];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = lAB.start;
    mp.end = lAB.end;
    
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.point = mp;
    pl2.line = lAB;
    
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip andPointOnRadius:lAB.start];

    
    for (id object in objects) {
        if (EqualPoints(object, ip)) return ip.position;
        if (PointOnCircle(object, c)) return Position(object);
        if (EqualCircles(object, c)) return c.center.position;
    }
    
    return CGPointMake(NAN, NAN);
}

- (void)showHint
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint) {
        [self hideHint];
        return;
    }
    
    self.showingHint = YES;
    
    [self slideOutToolbar];
    
    if (hint2_OK) {
        hint1_OK = NO;
        hint2_OK = NO;
    }
    
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.point = _givenLine.start;
    pl1.line = _givenLine;
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:_pA andEnd:_givenLine.start];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = lAB.start;
    mp.end = lAB.end;
    
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.point = mp;
    pl2.line = lAB;
    pl2.temporary = YES;
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip andPointOnRadius:lAB.start];
    c.temporary = YES;
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc]initWithLine:_givenLine andPoint:_givenLine.start];
    perp.temporary = YES;
    
    DHGeometryView* circleView = [[DHGeometryView alloc ]initWithObjects:@[c,ip] andSuperView:geometryView];
    DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:_givenLine.start andEnd:ip];
    segment.temporary = YES;
    
    DHLineSegment* segment2 = [[DHLineSegment alloc]initWithStart:_pA andEnd:ip];
    segment2.temporary = YES;
    DHLineSegment* segment3 = [[DHLineSegment alloc]initWithStart:_givenLine.start andEnd:_pA];
    segment3.temporary = YES;
    DHGeometryView* bisectorView = [[DHGeometryView alloc]initWithObjects:@[segment3,mp,pl2] andSuperView:geometryView];

    
    DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[segment] andSuperView:geometryView];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        [geometryView addSubview:hintView];
        [hintView addSubview:bisectorView];
        [hintView addSubview:circleView];
        [hintView addSubview:perpView];

        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(30,400) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,500)];
        }
        
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        if (!hint1_OK) {
            [self afterDelay:0.0 performBlock:^{
                //[message1 text:@"Which properties does a circle have if it is tangent to a line?"];
                [message1 text:@"一条与圆相切的直线有什么特性呢?"];
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:circleView withDuration:1.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                //[message1 appendLine:@"What do we know about the line connecting the center with the tangent point?"
                [message1 appendLine:@"关于圆和切点的连线具有什么样的特性呢?"
                        withDuration:1.0];
            }];
            [self afterDelay:8.0 performBlock:^{
                //[message1 appendLine:@"It is an interesting fact, we learned in Level 13."
                [message1 appendLine:@"有一个非常有趣的特性，我们在挑战-14中学到过。"
                        withDuration:1.0];
                [self fadeIn:perpView withDuration:2.0];
                
                hint1_OK = YES;
            }];
        }
        else if (!hint2_OK) {
            
            [self afterDelay:0.0 performBlock:^{
                //[message1 text:@"We know that the circle must pass through A and B."];
                [message1 text:@"我们知道这个圆肯定是要经过点A和点B的。"];
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:circleView withDuration:1.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                //[message1 appendLine:@"So A and B are equidistant from the center."
                [message1 appendLine:@"所以点A和点B到圆心的距离是等距的。"
                        withDuration:1.0];
                
                [perpView.geometricObjects addObject:segment2];
                [perpView setNeedsDisplay];
                [self fadeIn:perpView withDuration:2.0];
            }];
            
            [self afterDelay:8.0 performBlock:^{
                //[message1 appendLine:@"What do we know about the perpendicular bisector of line segment AB?"
                [message1 appendLine:@"关于线段AB的垂直平分线我们知道点什么呢?"
                        withDuration:1.0];
            }];
            
            [self afterDelay:12.0 performBlock:^{
                //[message1 appendLine:@"It is an interesting fact we learned in Level 14."
                [message1 appendLine:@"这个非常有趣的特性，我们在挑战-13中学到过。"
                        withDuration:1.0];
                [self fadeIn:bisectorView withDuration:2.0];
                
                hint2_OK = YES;
            }];
        }
    }];
    
}

@end
