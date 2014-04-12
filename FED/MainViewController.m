//
//  MainViewController.m
//  FED
//
//  Created by Nattawut Singhchai on 4/12/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "MainViewController.h"
#import "User.h"
#import "Food.h"
#import "FoodHelper.h"
#import "FoodListCell.h"
#import <StandardPaths/StandardPaths.h>
#import "FoodeEditorViewController.h"

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMenuConstrant;
@property (nonatomic,retain) User *user;
@property (weak, nonatomic) IBOutlet UIButton *editUserButton;
@property (weak, nonatomic) IBOutlet UILabel *energyDisplayLabel;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong) NSMutableArray *filterdDataSource;

@end

static NSString *kFEDUserKey = @"FED_USER_KEY";
static NSString *kFEDDataFileName = @"FED.DAT";
@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kFEDUserKey];
    if (data)
    _user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!_user) {
        [self performSegueWithIdentifier:@"editUser" sender:_editUserButton];
    }
    
    NSLog(@"MBR : %f",_user.MBR);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FED_SAVE" object:nil queue:self.queue usingBlock:^(NSNotification *note) {
        [self save];
    }];
    
    [self displayInterface];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self save];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FED_SAVE" object:nil];
}

- (void)save
{
    NSString *dataSourcePath = [[[NSFileManager defaultManager] privateDataPath] stringByAppendingPathComponent:kFEDDataFileName];
    [NSKeyedArchiver archiveRootObject:_dataSource toFile:dataSourcePath];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self displayInterface];
    }];
    
}

- (void)displayInterface{
    [_energyDisplayLabel setText:[NSString stringWithFormat:@"%.2f K",  _user.MBR - [self summaryCalories]]];
    NSLog(@"%f - %f = %f",self.user.MBR , [self summaryCalories] , self.user.MBR - [self summaryCalories]);
    _progressView.progress =  ([self summaryCalories]/ _user.MBR );
    if (_progressView.progress < .20) {
        _progressView.progressTintColor = [UIColor greenColor];
    }else if (_progressView.progress < .50){
        _progressView.progressTintColor = [UIColor yellowColor];
    }else{
        _progressView.progressTintColor = [UIColor redColor];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.queue = [NSOperationQueue new];
    NSString *dataSourcePath = [[[NSFileManager defaultManager] privateDataPath] stringByAppendingPathComponent:kFEDDataFileName];
    NSLog(@"%@",dataSourcePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataSourcePath])
    {
        NSMutableArray *sample = [NSMutableArray new];
        NSArray *source = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"food" ofType:@"plist"]];
        for (NSDictionary *dict in source)
        {
            [sample addObject:[[FoodHelper alloc] initWithFood:[[Food alloc] initWithDictionary:dict]]];
        }
        [sample sortUsingComparator:^NSComparisonResult(FoodHelper *obj1, FoodHelper *obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
        [NSKeyedArchiver archiveRootObject:sample toFile:dataSourcePath];
    }else{
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataSourcePath error:nil];
        NSDate *date = [attributes fileModificationDate];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        if (![[dateFormatter stringFromDate:[NSDate new]] isEqualToString:[dateFormatter stringFromDate:date]]) {
            NSMutableArray *tmp  = [NSKeyedUnarchiver unarchiveObjectWithFile:dataSourcePath];
            for (NSData *data in tmp)
            {
                FoodHelper *food = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [food reset];
            }
            [NSKeyedArchiver archiveRootObject:tmp toFile:dataSourcePath];
        }
    }
    _dataSource = [NSKeyedUnarchiver unarchiveObjectWithFile:dataSourcePath];
    [_dataSource sortUsingComparator:^NSComparisonResult(FoodHelper *obj1, FoodHelper *obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    }];
    
    [self.queue addOperationWithBlock:^{
        [self save];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     if (tableView == self.tableView) {
         return _dataSource.count;
     }
    return self.filterdDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodListCell *cell ;
    if (tableView == self.tableView) {
       cell =  [self.tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    }else{
       cell =  [self.tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    }
    
    
    if (tableView == self.tableView) {
        cell.food = self.dataSource[indexPath.row];
    }else{
        cell.food = self.filterdDataSource[indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        FoodeEditorViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"foodEditor"];
        [vc setFood:self.dataSource[indexPath.row]];
        [vc setRemoveFood:^(FoodHelper *food) {
            [self.dataSource removeObject:food];
            [self.tableView reloadData];
            [self save];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    
    }
}

#pragma mark - Search Bar Delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (_topMenuConstrant.constant == 20) {
        return YES;
    }else{
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                  _topMenuConstrant.constant = 20;
                                  [self.view layoutIfNeeded];
                              } completion:^(BOOL finished) {
                                  [searchBar becomeFirstResponder];
                              }];
        return NO;
    }
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            _topMenuConstrant.constant = 278;
                            [self.view layoutIfNeeded];
                        } completion:^(BOOL finished) {
                            [self.tableView reloadData];
                        }];
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        return;
    }
    if (self.filterdDataSource.count) {
        [self.filterdDataSource removeAllObjects];
    }
    for (FoodHelper *food in _dataSource) {
        NSRange nameRange = [food.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound )
        {
            [self.filterdDataSource addObject:food];
        }
    }
    [self.tableView reloadData];
}

-(float)summaryCalories
{
    float sum = 0.0f;
    for (FoodHelper *food in _dataSource) {
        sum += food.summaryCalories;
    }
    return sum;
}
- (IBAction)random:(id)sender
{
    NSUInteger rand = arc4random() %_dataSource.count ;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rand inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

-(NSMutableArray *)filterdDataSource
{
    if (!_filterdDataSource) {
        _filterdDataSource = [NSMutableArray new];
    }
    return _filterdDataSource;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addNewFood"]) {
        FoodeEditorViewController *vc = segue.destinationViewController;
        [vc setAddedNewFood:^(FoodHelper *food) {
            [self.dataSource addObject:food];
            [self.tableView reloadData];
            [self save];
        }];
    }
}

@end
