//
//  SetingsV2TableViewController.m
//  sensorec
//
//  Created by Niladri Bora on 9/8/15.
//  Copyright © 2015 AHN. All rights reserved.
//

#import "SettingsV2TableViewController.h"
#import "CoachV2.h"
#import "SettingsDetailViewController.h"

static NSString* const CELL_ID = @"MyCell";

@interface SettingsV2TableViewController ()

@end

@interface MyCell : UITableViewCell

@end

@implementation MyCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleValue2
                reuseIdentifier:CELL_ID];
    return self;
}

@end

@implementation SettingsV2TableViewController{
    @private
    CoachV2* _coach;
    NSArray<NSString*>* _settingsKeys;
    NSString* _selectedParam;
}

- (void)createTableHeader {

//    UILabel* header  = [UILabel new];
//    CGRect hdrBounds = header.bounds;
//    hdrBounds.size.height = 60;
//    header.bounds = hdrBounds;
//    header.text = @"Coach Settings";
//    header.textAlignment = NSTextAlignmentCenter;
//    self.tableView.tableHeaderView = header;

    UIView* header  = [UIView new];
    CGRect hdrBounds = header.bounds;
    hdrBounds.size.height = 60;
    header.bounds = hdrBounds;
    UILabel* l = [UILabel new];
    [header addSubview:l];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.text = @"Coach Settings";
    l.textAlignment = NSTextAlignmentCenter;
    UIButton* b = [UIButton new];
    [header addSubview:b];
//    b.titleLabel.text = @"Close";
    [b setTitle:@"Close" forState:UIControlStateNormal];
    [b setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [b addTarget:self
          action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray<NSLayoutConstraint*>* constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:l
                                                        attribute:NSLayoutAttributeCenterX relatedBy:0
                                                           toItem:header
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:l
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:0
                                                           toItem:header
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:b.titleLabel
                                                        attribute:NSLayoutAttributeBaseline
                                                        relatedBy:0
                                                           toItem:l
                                                        attribute:NSLayoutAttributeBaseline
                                                       multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:b
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:0
                                                           toItem:header
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1 constant:0]];
    [NSLayoutConstraint activateConstraints:constraints];

    self.tableView.tableHeaderView = header;
}

-(IBAction)onClickClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[MyCell class]
           forCellReuseIdentifier:CELL_ID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self createTableHeader];
    _coach = [CoachV2 sharedInstance];
    _settingsKeys = @[@"bounce",@"cadence", @"lurch", @"plod", @"rotx", @"roty",
                      @"rotz"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ParamDetailSegue"]){
        SettingsDetailViewController* detailVc =
        (SettingsDetailViewController*)segue.destinationViewController;
        detailVc.parameterName = _selectedParam;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedParam = _settingsKeys[indexPath.row];
    NSLog(@"selected param=%@", _selectedParam);
    [self performSegueWithIdentifier:@"ParamDetailSegue" sender:nil];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID
                                                            forIndexPath:indexPath];
    if(!cell.textLabel.text || [cell.textLabel.text isEqualToString:@""]){
        //new cell
        NSString* paramName = _settingsKeys[indexPath.row];
        cell.textLabel.text = paramName.capitalizedString;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
