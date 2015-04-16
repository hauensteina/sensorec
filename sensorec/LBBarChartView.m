//
//  LBBarChartView.m
//
//  Created by Andreas Hauenstein on 2014-06-22.
//  Copyright (c) 2014 Lumo BodyTech. All rights reserved.
//

#import "LBBarChartView.h"
#import "Utils.h"

#define RGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define BLUE_FG RGB(0x66ccff)
#define BLUE_BG RGB(0x0033cc)
#define GRAY_BG RGB(0xd0d0d0)
#define GRAY_FG RGB(0x404040)

#define SCR_W [UIScreen mainScreen].bounds.size.width
#define SCR_H [UIScreen mainScreen].bounds.size.height
#define SCR_BOUNDS [UIScreen mainScreen].bounds


@interface LBBarChartView ()
@property UIFont *labFont;
@property UIFont *headFont;
@end

@implementation LBBarChartView

//--------------------------------
- (id)initWithFrame:(CGRect)frame
//--------------------------------
{
    self = [super initWithFrame:frame];
    if (self) {
        self.topMargin  = 50;
        self.title = @"Hello from BartChartView";
        self.titleSpace = 60;
        self.barHeight  = 10;
        //self.barSpace   = 5;
    }
    return self;
} // initWithFrame

//--------------------
- (void) makeHeading
//--------------------
{
    int headHeight = self.barHeight * 1.5;
    if (!self.title) { return; }
    UILabel *testLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(0, 0, SCR_W, headHeight)];
    if (!self.headFont) {
        self.headFont = [self findAdaptiveFontWithName:@"HelveticaNeue"
                                        forUILabelSize:testLabel.frame.size
                                       withMinimumSize:8];
    }
    // Screen heading
    UILabel *label = [[UILabel alloc] initWithFrame:
                      CGRectMake(0, self.topMargin, SCR_W, headHeight)];
    label.text = self.title;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = GRAY_FG;
    [label setFont:self.headFont];
    [self addSubview:label];
} // makeHeading

// Add a bar to a barchart
// Dictionary looks like
// @{@"label":@"Green"  ,@"color":RGB(0x00ff00), @"value":@(10), @"max":@(100)}
//----------------------------------------
- (void) addBar:(NSDictionary *) bar atPosition:(int)pos
//----------------------------------------
{
    if (!self.bars) {
        self.bars = [NSMutableArray new];
    }
    NSMutableDictionary *mbar = [bar mutableCopy];
    long nbars = [self.bars count];
    if (pos >= nbars) { // Just append
        [self.bars addObject:mbar];
    }
    else {
        [self.bars insertObject:mbar atIndex:pos];
    }
} // addBar

// Remove a bar
//----------------------------------------
- (void) rmBar:(NSString *) label
//----------------------------------------
{
    int remidx = -1;
    int idx = -1;
    for (NSDictionary *dict in self.bars) {
        idx++;
        if ([dict[@"label"] isEqualToString:label]) {
            remidx = idx;
            break;
        }
    }
    if (remidx >= 0) {
        [self.bars removeObjectAtIndex:remidx];
    }
} // rmBar

// Find bar with label
//----------------------------------------
- (NSMutableDictionary *)getBar:(NSString *) label
//----------------------------------------
{
    int getidx = -1;
    int idx = -1;
    for (NSDictionary *dict in self.bars) {
        idx++;
        if ([dict[@"label"] isEqualToString:label]) {
            getidx = idx;
            break;
        }
    }
    if (getidx >= 0) {
        return self.bars[getidx];
    }
    else return nil;
} // getBar

//----------------------------------------
- (void) setColor:(UIColor *)color
           forBar:(NSString *)label
//----------------------------------------
{
    int setidx = -1;
    int idx = -1;
    for (NSDictionary *dict in self.bars) {
        idx++;
        if ([dict[@"label"] isEqualToString:label]) {
            setidx = idx;
            break;
        }
    }
    if (setidx >= 0) {
        self.bars[setidx][@"color"] = color;
    }
} // setColor

//----------------------------------------
- (void) setValue:(NSNumber *)val
           forBar:(NSString *)label
//----------------------------------------
{
    int setidx = -1;
    int idx = -1;
    for (NSDictionary *dict in self.bars) {
        idx++;
        if ([dict[@"label"] isEqualToString:label]) {
            setidx = idx;
            break;
        }
    }
    if (setidx >= 0) {
        self.bars[setidx][@"value"] = val;
    }
} // setColor

// Called each time the view redraws
//------------------------------
- (void)drawRect:(CGRect)rect
//------------------------------
{
    //[self setTestProperties];
    if (!self.bars) { return; }
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Remove all subviews
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self makeHeading];
    
    // Common label properties
    float leftMargin = SCR_W / 20;
    float labHeight = self.barHeight;
    UILabel *testLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(0, 0, SCR_W, labHeight)];
    if (!self.labFont) {
        self.labFont = [self findAdaptiveFontWithName:@"HelveticaNeue"
                                       forUILabelSize:testLabel.frame.size
                                      withMinimumSize:8];
    }
    // Show all bar labels
    int line = -1;
    float maxWidth = 0;
    for (NSDictionary *bar in self.bars) {
        line++;
        float y =
        self.topMargin + self.titleSpace + line * (labHeight + self.barHeight) + self.barHeight / 2.0;
        UILabel *label = [[UILabel alloc] initWithFrame:
                          CGRectMake(leftMargin, y, SCR_W, labHeight)];
        label.numberOfLines = 1;
        [label setFont:self.labFont];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = bar[@"label"];

        CGSize textSize = [label.text sizeWithAttributes:@{ NSFontAttributeName :self.labFont}];
        if (textSize.width > maxWidth) { maxWidth = textSize.width; }
        //label.font = [UIFont boldSystemFontOfSize: IS_IPHONE ? 32 : 64];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
    }
    
    float textBarSpace = SCR_W / 50;
    float barLeft = leftMargin + maxWidth + textBarSpace;
    float rightMargin = SCR_W / 20;
    float maxBarLen = SCR_W - barLeft - rightMargin;
    
    // Draw the bars
    line = -1;
    for (NSMutableDictionary *bar in self.bars) {
        line++;
        float val = [bar[@"value"] floatValue];
        NSString *valtxt;
        if (val < 10) {
            valtxt = nsprintf(@"%.2f",val);
        }
        else {
            valtxt = nsprintf(@"%.0f",val);
        }
        int nobar = [bar[@"nobar"] intValue];
        if (nobar) { // No bar, we just show a number
            float y =
            self.topMargin + self.titleSpace + line * (labHeight + self.barHeight) + self.barHeight / 2.0;
            UILabel *vlabel = [[UILabel alloc] initWithFrame:
                               CGRectMake (barLeft, y, SCR_W - rightMargin, labHeight)];
            vlabel.text = valtxt;
            vlabel.textAlignment = NSTextAlignmentLeft;
            vlabel.backgroundColor = [UIColor clearColor];
            vlabel.textColor = GRAY_FG;
            [vlabel setFont:self.labFont];
            [self addSubview:vlabel];
        }
        else { // show bar
            float y =
            self.topMargin + self.titleSpace + line * (labHeight + self.barHeight) - self.barHeight / 2.0;
            // Show max value to the right
            UILabel *label = [[UILabel alloc] initWithFrame:
                              CGRectMake(0, y, SCR_W - rightMargin, labHeight)];
            label.textAlignment = NSTextAlignmentRight;
            float mmax = 0;
            if (bar[@"max"]) {
                mmax = [bar[@"max"] floatValue];
            }
            // Give some more room if we hit the limit
            if (val > mmax) {
                mmax = 1.2 * val;
                bar[@"max"] = @(mmax);
            }
            label.text = valtxt;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = GRAY_FG;
            [label setFont:self.labFont];
            [self addSubview:label];
            
            // Show the bar
            y += labHeight + self.barHeight / 2.0;
            // *_min will change color for the part exceeding the value
            float orange_min = [bar[@"orange_min"] floatValue];
            float red_min = [bar[@"red_min"] floatValue];
            if (!orange_min) { orange_min = FLT_MAX; }
            if (!red_min)    { red_min = FLT_MAX; }
            // *_max will change whole bar color if you fall under the threshold
            float orange_max = [bar[@"orange_max"] floatValue];
            float red_max = [bar[@"red_max"] floatValue]; // must be smaller
            if (!orange_max) { orange_max = 0; }
            if (!red_max)    { red_max = 0; }

            if (!bar[@"show_alert_colors"]) {
                orange_max = 0; red_max = 0;
                orange_min = FLT_MAX; red_min = FLT_MAX;
            }
        
            do {
                float val1,len;
                // Normal color part
                val1 = val;
                if (val1 > orange_min) { val1 = orange_min; }
                len = mmax>0?((val1 / mmax) * maxBarLen):0;
                CGContextSetLineWidth (context, self.barHeight);
                if (val1 < red_max) {
                    CGContextSetStrokeColorWithColor (context, RGB(0xe50000).CGColor);
                }
                else if (val < orange_max) {
                    CGContextSetStrokeColorWithColor (context, RGB(0xffa500).CGColor);
                }
                else {
                    CGContextSetStrokeColorWithColor (context, ((UIColor *)bar[@"color"]).CGColor);
                }
                CGContextMoveToPoint (context, barLeft, y);
                CGContextAddLineToPoint (context, barLeft + len, y);
                CGContextStrokePath (context);
                if (val <= orange_min) { break; }
                if (red_max || orange_max) { break; }
                
                // Orange part
                CGContextMoveToPoint (context, barLeft + len, y);
                val1 = val;
                if (val1 > red_min) { val1 = red_min; }
                len = mmax>0?((val1 / mmax) * maxBarLen):0;
                CGContextSetLineWidth (context, self.barHeight);
                CGContextSetStrokeColorWithColor (context, RGB(0xffa500).CGColor);
                CGContextAddLineToPoint (context, barLeft + len, y);
                CGContextStrokePath (context);
                if (val <= red_min) { break; }
                
                // Red part
                CGContextMoveToPoint (context, barLeft + len, y);
                val1 = val;
                len = mmax>0?((val1 / mmax) * maxBarLen):0;
                CGContextSetLineWidth (context, self.barHeight);
                CGContextSetStrokeColorWithColor (context, RGB(0xe50000).CGColor);
                CGContextAddLineToPoint (context, barLeft + len, y);
                CGContextStrokePath (context);
            } while (0);
        } // else show bar
    } // for all bars
} // drawRect

// Find a font size to fit the height of a label
// Usage:
// [self findAdaptiveFontWithName:@"HelveticaNeue-UltraLight"
//                   forUILabelSize:self.myLabel.frame.size
//                  withMinimumSize:30];
//----------------------------------------------------------
- (UIFont *)findAdaptiveFontWithName:(NSString *)fontName
                      forUILabelSize:(CGSize)labelSize
                     withMinimumSize:(NSInteger)minSize
//----------------------------------------------------------
{
    UIFont *tempFont = nil;
    NSString *testString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSInteger tempMin = minSize;
    NSInteger tempMax = 256;
    NSInteger mid = 0;
    NSInteger difference = 0;
    
    while (tempMin <= tempMax) {
        mid = tempMin + (tempMax - tempMin) / 2;
        tempFont = [UIFont fontWithName:fontName size:mid];
        //difference = labelSize.height - [testString sizeWithFont:tempFont].height;
        CGSize textSize = [testString sizeWithAttributes:@{ NSFontAttributeName : tempFont}];
        difference = labelSize.height - textSize.height;
        
        if (mid == tempMin || mid == tempMax) {
            if (difference < 0) {
                return [UIFont fontWithName:fontName size:(mid - 1)];
            }
            return [UIFont fontWithName:fontName size:mid];
        }
        if (difference < 0) {
            tempMax = mid - 1;
        } else if (difference > 0) {
            tempMin = mid + 1;
        } else {
            return [UIFont fontWithName:fontName size:mid];
        }
    } // while
    return [UIFont fontWithName:fontName size:mid];
} // findAdaptiveFontWithName

//--------------------------
- (void) setTestProperties
//--------------------------
{
    self.topMargin  = 50;
    self.title = @"BarChart Test";
    self.titleSpace = 60;
    self.barHeight  = 10;
    //self.barSpace   = 5;
    [self addBar: @{@"label":@"Green"  ,@"color":RGB(0x00ff00), @"value":@(10)}
      atPosition:0];
    [self addBar: @{@"label":@"Yellow" ,@"color":RGB(0xffff00), @"value":@(20)}
      atPosition:1];
    [self addBar: @{@"label":@"Red"    ,@"color":RGB(0xff0000), @"value":@(30)}
      atPosition:2];
    
} // setTestProperties

@end

