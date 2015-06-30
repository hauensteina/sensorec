//
//  AutolayoutUtils.h
//  LUMOLift
//
//  Created by Niladri Bora on 9/2/14.
//  Copyright (c) 2014 LUMO BodyTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSArray* VF_CONSTRAINT(NSString* formatStr, NSDictionary* metrics, NSDictionary* views);



@interface UIView (AutoLayoutExtensions)

+ (UIView*) viewForAutoLayoutAsSubViewOf: (UIView*) sv;

+ (UILabel*) labelForAutoLayoutAsSubViewOf: (UIView*) sv;

+ (UIButton*) buttonForAutoLayoutAsSubViewOf: (UIView*) sv;

+ (UIImageView*) imageViewForAutoLayoutAsSubViewOf: (UIView*) sv;

- (void)exerciseAmbiguityInLayoutRepeatedly:(BOOL)recursive;

+ (void) listConstraints:( UIView*) v isRecursive:(BOOL) r;
@end
