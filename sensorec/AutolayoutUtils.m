//
//  AutolayoutUtils.m
//  LUMOLift
//
//  Created by Niladri Bora on 9/2/14.
//  Copyright (c) 2014 LUMO BodyTech. All rights reserved.
//

#import "AutolayoutUtils.h"

NSArray* VF_CONSTRAINT(NSString* formatStr, NSDictionary* metrics,
                       NSDictionary* views)
{
    return [NSLayoutConstraint
            constraintsWithVisualFormat:formatStr options:0 metrics:metrics
            views:views];
}

@implementation UIView (AutoLayoutExtensions)

+ (UIView*) viewForAutoLayoutAsSubViewOf: (UIView*) sv
{
    UIView* v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addSubview:v];
    return v;
}

+ (UILabel*) labelForAutoLayoutAsSubViewOf: (UIView*) sv
{
    UILabel* l = [[UILabel alloc] init];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addSubview:l];
    return l;
}

+ (UIButton*) buttonForAutoLayoutAsSubViewOf: (UIView*) sv
{
    UIButton* b = [[UIButton alloc] init];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addSubview:b];
    return b;
}

+ (UIImageView*) imageViewForAutoLayoutAsSubViewOf: (UIView*) sv
{
    UIImageView* iv = [[UIImageView alloc] init];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addSubview:iv];
    return iv;
}

- (void)exerciseAmbiguityInLayoutRepeatedly:(BOOL)recursive
{
#ifdef DEBUG
    if (self.hasAmbiguousLayout) {
        [NSTimer scheduledTimerWithTimeInterval:.5
                                         target:self
                                       selector:@selector(exerciseAmbiguityInLayout)
                                       userInfo:nil
                                        repeats:YES];
    }
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview exerciseAmbiguityInLayoutRepeatedly:YES];
        }
    }
#endif
}

+ (void) listConstraints:( UIView*) v isRecursive:(BOOL) r
{
#ifdef DEBUG
    
    if (nil == v)
        v = [[ UIApplication sharedApplication] keyWindow];
    NSArray* arr1 = [v constraintsAffectingLayoutForAxis: 0];
    NSArray* arr2 = [v constraintsAffectingLayoutForAxis: 1];
    NSLog(@"%@\nH: %@\nV:%@", v, arr1, arr2);
    if(r){
        for (UIView* vv in v.subviews) {
            [self listConstraints:vv isRecursive:r];
            //        NSArray* arr1 = [vv constraintsAffectingLayoutForAxis: 0];
            //        NSArray* arr2 = [vv constraintsAffectingLayoutForAxis: 1];
            //        NSLog(@"%@\nH: %@\nV:%@", vv, arr1, arr2);
            //        if (vv.subviews.count && r)
            //            [self listConstraints:vv isRecursive:r];
        }
    }
#endif
}
@end
