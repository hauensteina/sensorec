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

//========================
@interface ConsoleVC ()
//========================

@property (weak, nonatomic) IBOutlet UITextView *tvConsole;
@property (weak, nonatomic) IBOutlet UITextField *tfCmd;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnStop;
@property NSMutableArray *logBuf; // Buffered lines while not scrolling
@property UIFont *largeLogFont;
@property UIFont *smallLogFont;
@property BOOL shouldScroll;
//@property NSString *strBuf;

@end // ConsoleVC

//========================
@implementation ConsoleVC
//========================

//---------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // The font we use for logging
    _largeLogFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:18];
    _smallLogFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:12];
    _shouldScroll = YES;
    _tfCmd.delegate = self;
}

//---------------------------------
- (IBAction)btnBack:(id)sender
{
    [g_app.naviVc popViewControllerAnimated:YES];
}

//---------------------------------
- (IBAction)btnStop:(id)sender
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
// Print a string to the console, in the given color
//----------------------------------------------------------------------
- (void) pr_impl:(NSString *)str
           color:(UIColor *)color
           small:(BOOL)small
{
    UIFont *font = self.largeLogFont;
    if (small) { font = self.smallLogFont; }
    
    //str = nsprintf(@"%@\n",str);
    UITextView *tv = self.tvConsole;
    if (!tv) {
        //NSLog(@"pr_impl:textView nil");
        return;
    }
    NSTextStorage *ts = tv.textStorage;
    NSAttributedString *astr =
    [[NSAttributedString alloc]
     initWithString: str
     attributes: @{
                   NSFontAttributeName: font,
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

#define LINE_NUM_COL RGB(0x404040)

// Print keys and values color coded.
// With the specified line number.
//----------------------------------------------------------------------
- (void) prdict:(NSDictionary *)kv
            num:(int)num
{
    dispatch_async (dispatch_get_main_queue(), ^{
        NSArray *keys = kv[@"orderedkeys"];
        [self pr_impl:@"\n" color:RED small:NO];
        // for (long i = [keys count]-1; i>=0; i--) {
        for (NSString *key in [[keys reverseObjectEnumerator] allObjects]) {
            //[self pr_impl:values[i] color:RGB(0xc3741c)];
            //[self pr_impl:values[i] color:RGB(0x8c00ec)];
            [self pr_impl:str(kv[key]) color:RGB(0x0f7002) small:NO];
            [self pr_impl:@" " color:RED small:NO];
            [self pr_impl:key color:RED small:NO];
            [self pr_impl:@" " color:RED small:NO];
        }
      //  if (_strBuf) { [self pr_impl:_strBuf color:BLUE]; }
      //  _strBuf = nil;
        [self pr_impl:nsprintf(@"%ld ",num) color:LINE_NUM_COL small:NO];
    });
} // pr:values:

// Print a string to the console, with line num
//----------------------------------------------------------------------
- (void) pr:(NSString *)str
        num:(int)num
{
    dispatch_async (dispatch_get_main_queue(), ^{
        [self pr_impl:@"\n" color:BLUE small:YES];
        [self pr_impl:str color:BLUE small:YES];
        [self pr_impl:nsprintf(@"%ld ",num) color:LINE_NUM_COL small:YES];
    });
}

// Print a string to the console, in Black
//----------------------------------------------------------------------
- (void) pr:(NSString *)str
{
    dispatch_async (dispatch_get_main_queue(), ^{
        [self pr_impl:str color:BLACK small:YES];
    });
} // pr

#pragma mark UITextFieldDelegate
//-------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSString *cmd = textField.text;
    [self pr:@"\n"];
    [self pr:cmd];
    
    NSMutableArray *parts = [[cmd componentsSeparatedByString: @" "] mutableCopy];
    if (parts.count) {
        NSString *command = [parts objectAtIndex: 0];
        [parts removeObjectAtIndex: 0];
        NSString *jsonstr;
        if (parts.count) {
            jsonstr = nsprintf (@"{\"CMD\":\"%@:%@\"}"
                                , command
                                , [parts componentsJoinedByString: @","]);
        } else {
            jsonstr = nsprintf (@"{\"CMD\":\"%@\"}"
                                , command );
        }
        LBJSONCommand* jsonCommand = [[LBJSONCommand alloc] initWithJSON:jsonstr];
        [g_app.connectVc.peripheral sendCommand:jsonCommand];
    }
    
    [textField resignFirstResponder];
    return YES;
}


@end
