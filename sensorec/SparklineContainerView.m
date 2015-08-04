//
//  SparklineContainerView.m
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import "SparklineContainerView.h"
#import "AutolayoutUtils.h"
#import "SparklineTileView.h"
#import "SparklineView.h"
@import AVFoundation;

@implementation SparklinePlotType

+(instancetype) newWithMetricName:(NSString*) name
                         maxValue:(NSNumber*) maxValue
                            color:(UIColor*) color{
    SparklinePlotType* inst = [[SparklinePlotType alloc] init];
    inst.metricName = name;
    inst.maxValue = maxValue;
    inst.color = color;
    return inst;
}

@end


@interface SparklineContainerView()<AVSpeechSynthesizerDelegate>
@property(assign, nonatomic) long numViews;
@property(weak, nonatomic) UIScrollView* scrollView;
@property(strong, nonatomic) NSArray* rightEdgeConstraints;
@property(strong, nonatomic) NSArray* plotTypes;
@property(weak, nonatomic) UILabel* tipLabel;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property(nonatomic, strong) NSMutableArray* tipsToSpeak;
@end

@implementation SparklineContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes{
    self = [[SparklineContainerView alloc]
            initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self){
        _numViews = plotTypes.count;
        _plotTypes = plotTypes;
        _tileViews = [NSMutableArray new];
        _rightEdgeConstraints = [NSMutableArray new];
        _speechSynthesizer = [AVSpeechSynthesizer new];
        _speechSynthesizer.delegate = self;
        _tipsToSpeak = [NSMutableArray new];
    }
    return self;
}

-(void) doLayout:(id<UIScrollViewDelegate>) delegate{
    UILabel* tipLabel = [UIView labelForAutoLayoutAsSubViewOf:self];
    tipLabel.text = @"You are doing great";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel = tipLabel;
    [self addConstraints:VF_CONSTRAINT(@"H:|[tipLabel]|", nil,
                                       NSDictionaryOfVariableBindings(tipLabel))];
    UIScrollView* sv = [UIScrollView new];
    sv.delegate =  delegate;
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    sv.backgroundColor = [UIColor clearColor];
    [self addSubview:sv];
    [self addConstraints:VF_CONSTRAINT(@"H:|[sv]|", nil,
                                       NSDictionaryOfVariableBindings(sv))];
    [self addConstraints:VF_CONSTRAINT(@"V:|[tipLabel][sv]|", nil,
                                       NSDictionaryOfVariableBindings(sv, tipLabel))];
    self.scrollView = sv;
}

-(void) plotPoints:(NSDictionary*) points{
    //figure out how whether we need a new tile to plot the latest points
    if(self.tileViews.count == 0){
        [self addTile];
    }
    [(SparklineTileView*)self.tileViews.lastObject plotPoints:points];
}

-(void) postTips:(NSArray*) tips
      withColor:(UIColor*) tipColor{
    self.tipLabel.textColor = tipColor;
    [self.tipsToSpeak addObjectsFromArray:tips];
    [self speak];
}

-(void) speak{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.tipsToSpeak.count == 0)
            return;
        NSString* tip = self.tipsToSpeak[0];
        self.tipLabel.text = tip;
        [self.tipLabel setNeedsDisplay];
        [self.tipsToSpeak removeObjectAtIndex:0];
        AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:tip];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        utterance.preUtteranceDelay = 0.2f;
        utterance.postUtteranceDelay = 0.2f;
        [self.speechSynthesizer speakUtterance:utterance];
    });
}

-(void) addTile{
    SparklineTileView* newTile = [[SparklineTileView alloc]
                                  initWithPlotTypes:self.plotTypes
                                  withTileIdx:self.tileViews.count];
    newTile.translatesAutoresizingMaskIntoConstraints = NO;
    newTile.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:newTile];
    [newTile doLayout:self.scrollView withContainerView:self];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:newTile
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:0
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1 constant:-20/*top margin*/]];
    [self.scrollView addConstraints:VF_CONSTRAINT(@"V:|-20-[newTile]|", nil,
                                                  NSDictionaryOfVariableBindings(newTile))];
    NSUInteger currSize = self.tileViews.count;
    if(currSize){
        //hide labels old tile
        SparklineTileView* lastTile = self.tileViews[currSize-1];
        for(SparklineView* slv in lastTile.sparklineViews){
            slv.label.hidden = YES;
        }
        //Now go ahead and layout new tile
        [self.scrollView removeConstraints:self.rightEdgeConstraints];
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:[lastTile][newTile]", nil,
                                                      NSDictionaryOfVariableBindings(newTile, lastTile))];
    }
    else{
        //first tile
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:|[newTile]", nil
                                                      , NSDictionaryOfVariableBindings(newTile))];

    }
    self.rightEdgeConstraints = VF_CONSTRAINT(@"H:[newTile]|", nil
                                              , NSDictionaryOfVariableBindings(newTile));
    [self.scrollView addConstraints:self.rightEdgeConstraints];
    [self.tileViews addObject:newTile];
}

#pragma mark - AVSpeechSynthesizerDelegate
-(void) speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
 didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    [self speak];
}
@end
