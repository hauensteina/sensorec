//
//  ConsoleVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-03-17.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "ConsoleVC.h"
#import "common.h"
#import "Utils.h"
#import "../SensoPlexLibrary/SensoPlex.h"

//========================
@interface ConsoleVC ()
//========================

@property (weak, nonatomic) IBOutlet UITextView *tvConsole;
@property (weak, nonatomic) IBOutlet UITextField *tfCmd;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnStop;
@property NSMutableArray *logBuf; // Buffered lines while not scrolling
@property UIFont *logFont;
@property BOOL shouldScroll;

@end // ConsoleVC

//========================
@implementation ConsoleVC
//========================

//---------------------------------
- (void)viewDidLoad
//---------------------------------
{
    [super viewDidLoad];
    // The font we use for logging
    _logFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
    _shouldScroll = YES;
    _tfCmd.delegate = self;
}

//---------------------------------
- (IBAction)btnBack:(id)sender
//---------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
}

//---------------------------------
- (IBAction)btnStop:(id)sender
//---------------------------------
{
    if (_shouldScroll) {
        _shouldScroll = NO;
        [_btnStop setTitle:@"Scroll"];
    } else {
        _shouldScroll = YES;
        [_btnStop setTitle:@"Stop"];
    }
}

#pragma mark printing
//----------------------------------------------------------------------
- (void) pr_impl:(NSString *)str
           color:(UIColor *)color
//----------------------------------------------------------------------
// Print a string to the console, in the given color
{
    //str = nsprintf(@"%@\n",str);
    UITextView *tv = self.tvConsole;
    if (!tv) {
        NSLog(@"pr_impl:textView nil");
        return;
    }
    NSTextStorage *ts = tv.textStorage;
    NSAttributedString *astr =
    [[NSAttributedString alloc]
     initWithString: str
     attributes: @{
                   NSFontAttributeName: self.logFont,
                   NSForegroundColorAttributeName: color
                   }];
    if (self.shouldScroll) { // Display immediately
        [ts beginEditing];
        if (self.logBuf) {
            for (NSAttributedString *as in self.logBuf) {
                [ts insertAttributedString:as atIndex:0];
            }
            self.logBuf = nil;
        }
        [ts insertAttributedString:astr atIndex:0];
        [ts endEditing];
        [self.tvConsole scrollRangeToVisible: NSMakeRange(0, 0)];
    }
    else { // We're not scrolling, buffer for later display
        if (!self.logBuf) {
            self.logBuf = [NSMutableArray new];
        }
        [self.logBuf addObject:astr];
    }
    // Limit the size of the backlog
    const int MAX_BACKLOG_LINES = 1000;
    if (self.logBuf.count > MAX_BACKLOG_LINES) {
        [self.logBuf
         removeObjectsAtIndexes:[NSIndexSet
                                 indexSetWithIndexesInRange:NSMakeRange(0,MAX_BACKLOG_LINES/2)]];
    }
    // Limit size of text storage
    const int MAX_TS_CHARS = 10 * 1000;
    if ([ts length] > MAX_TS_CHARS) {
        [ts beginEditing];
        [ts deleteCharactersInRange: NSMakeRange(MAX_TS_CHARS/2, [ts length]-MAX_TS_CHARS/2)];
        [ts endEditing];
    }
} // pr_impl

//=== Public print methods to make sure we log on the main thread

//----------------------------------------------------------------------
- (void) pr:(NSString *)str
      color:(UIColor *)color
//----------------------------------------------------------------------
// Print a string to the console, in the given color
{
    dispatch_async (dispatch_get_main_queue(), ^{
        [self pr_impl:str color:color];
    });
} // pr:color:

//----------------------------------------------------------------------
- (void) pr:(NSString *)str
//----------------------------------------------------------------------
// Print a string to the console, in Black
{
    dispatch_async (dispatch_get_main_queue(), ^{
        [self pr_impl:str color:BLACK];
    });
} // pr

#pragma mark UITextFieldDelegate
//-------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------
{
    NSString *cmd = textField.text;
    [self pr:@"\n"];
    [self pr:cmd];
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    [senso sendString:cmd];
    
    [textField resignFirstResponder];
    return YES;
}


@end
