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
#import <BlocksKit/BlocksKit+UIKit.h>

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    BOOL isEatMode;
}
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMenuConstrant;
@property (nonatomic,retain) User *user;
@property (weak, nonatomic) IBOutlet UIButton *editUserButton;
@property (weak, nonatomic) IBOutlet UILabel *energyDisplayLabel;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong) NSMutableArray *filterdDataSource;
@property (nonatomic,assign) float currentEnergy;
@property (weak, nonatomic) IBOutlet UIImageView *progressImage;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *progressRightSpace;
@property (nonatomic,strong) NSMutableArray *ateFood;
@end

static NSString *kFEDUserKey = @"FED_USER_KEY";
static NSString *kFEDDataFileName = @"FED.DAT";
@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kFEDUserKey];
    NSLog(@"data : %@",data);
    if (data)
    _user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    NSLog(@"MBR : %f",_user.MBR);
    
    if (!_user) {
        [self performSegueWithIdentifier:@"editUser" sender:_editUserButton];
    }else{
        [self displayInterface];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"FED_SAVE" object:nil queue:self.queue usingBlock:^(NSNotification *note) {
            [self save];
        }];
    }
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_user)
    {
        [self save];
    }
    
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
    self.currentEnergy=  _user.MBR - [self summaryCalories];
    
    [_energyDisplayLabel setText:[NSString stringWithFormat:@"%.2f K", self.currentEnergy]];
    NSLog(@"%f - %f = %f",self.user.MBR , [self summaryCalories] , self.user.MBR - [self summaryCalories]);
    [_energyDisplayLabel setTextColor:self.currentEnergy >= 0 ? [UIColor colorWithRed:0 green:0.6 blue:.2 alpha:1.0]:[UIColor redColor]];
    
    CGFloat progressWidth = 207.0f;
    CGFloat rightDefaultSpace = 3.0f;
    CGFloat aspectWidth = progressWidth * ([self summaryCalories]/ _user.MBR );
    CGFloat rightSpace = (progressWidth - aspectWidth) + rightDefaultSpace;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.progressRightSpace.constant = rightSpace;
                            [self.view layoutIfNeeded];
                        } completion:^(BOOL finished) {
                        }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.queue = [NSOperationQueue new];
    self.ateFood = [NSMutableArray new];
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
            for (FoodHelper *food in tmp)
            {
                [food reset];
            }
            [NSKeyedArchiver archiveRootObject:tmp toFile:dataSourcePath];
        }
    }
    _dataSource = [NSKeyedUnarchiver unarchiveObjectWithFile:dataSourcePath];
    [_dataSource sortUsingComparator:^NSComparisonResult(FoodHelper *obj1, FoodHelper *obj2) {
        return [obj1.name caseInsensitiveCompare:obj2.name];
    }];
    
    if (_user) {
        [self.queue addOperationWithBlock:^{
            [self save];
        }];
    }
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
         return isEatMode ? self.ateFood.count :  _dataSource.count;
     }
    return  self.filterdDataSource.count;
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
        cell.food = isEatMode ? self.ateFood[indexPath.row] : self.dataSource[indexPath.row];
    }else{
        cell.food = self.filterdDataSource[indexPath.row];
    }
    cell.food.nearFull = NO;
    [cell setBackgroundColor:cell.food.quantity == 0 ? [UIColor colorWithRed:234.f/255.f green:1.0f blue:243.f/255.f alpha:1.0f]:[UIColor colorWithRed:136.f/255.f green:253.f/255.f blue:202.f/255.f alpha:1.0f]];
    if (_user.MBR - [self summaryCalories] < cell.food.energy) {
        [cell setBackgroundColor:[UIColor colorWithRed:1 green:101.0/255.0 blue:103.0/255.0 alpha:1.0]];
        cell.food.nearFull = YES;
    }
    cell.food.isFull = (_user.MBR - [self summaryCalories] ) <=  0 ;
    
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
    NSArray *target = isEatMode ? _ateFood : _dataSource;
    for (FoodHelper *food in target) {
        NSRange nameRange = [food.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound )
        {
            [self.filterdDataSource addObject:food];
        }
    }
    [self.tableView reloadData];
}

- (IBAction)valChanged:(id)sender
{
    FoodListCell *cell = (FoodListCell *)sender;
    do {
        cell = (FoodListCell *)cell.superview;
    } while (![cell isKindOfClass:[FoodListCell class]] || cell == nil);
    
    if (cell) {
        UITableView *tableView = self.searchDisplayController.isActive ? self.searchDisplayController.searchResultsTableView : self.tableView ;
        [tableView reloadData];
    }
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
    NSArray *mainData = isEatMode ? self.ateFood : self.dataSource;
    NSMutableArray *avaliableData = [NSMutableArray new];
    for (FoodHelper *food in mainData) {
        if (food.energy <= (( _user.MBR - [self summaryCalories])))
        {
            [avaliableData addObject:food];
        }
    }
    
    if ([avaliableData count]) {
        NSUInteger rand = arc4random() % avaliableData.count ;
        NSUInteger index = [mainData indexOfObject:avaliableData[rand]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }else{
        UIAlertView *alertView =    [UIAlertView bk_alertViewWithTitle:@"Error" message:@"ไม่มีอาหารที่เหมาะสม"];
        [alertView bk_addButtonWithTitle:@"ตกลง" handler:nil];
        [alertView show];
    }
    
    avaliableData = nil;
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
- (IBAction)didToggle:(UIButton *)sender
{
    isEatMode = !isEatMode;
    if (isEatMode) {
        [self.ateFood removeAllObjects];
        for (FoodHelper *food in self.dataSource) {
            if (food.quantity > 0) {
                [self.ateFood addObject:food];
            }
        }
       
    }
    [sender setBackgroundImage:[UIImage imageNamed:isEatMode?@"FED_Dish":@"FED_Burger"] forState:UIControlStateNormal];
    [self.tableView reloadData];
}

@end
