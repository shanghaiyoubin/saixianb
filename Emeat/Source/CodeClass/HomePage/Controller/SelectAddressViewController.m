//
//  SelectAddressViewController.m
//  Emeat
//
//  Created by liuheshun on 2017/12/4.
//  Copyright © 2017年 liuheshun. All rights reserved.
//

#import "SelectAddressViewController.h"
#import "AddNewAddressViewController.h"
#import "CurrentAddressView.h"
#import "RHLocation.h"
#import "DDSearchManager.h"
#import "MyAddressView.h"
#import "IQKeyboardManager.h"
#import "MyAddressTableViewCell.h"
#import "SearchLocationAddressTableViewCell.h"

@interface SelectAddressViewController ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,RHLocationDelegate ,UISearchResultsUpdating, UISearchBarDelegate>

#define searchBgViewHeight 55

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) CurrentAddressView *currentAddressView;
//定位
//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong) RHLocation *rhLocation;

//搜索
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *results;
//@property (nonatomic, strong) UIView *customNavBar;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic,strong) NSString *searchBarState;

@property (nonatomic,strong) MyAddressView *myAddressView;



@end

@implementation SelectAddressViewController

{
    BOOL  _isFinishedAnimation;
    CGFloat angle;
    
}
// 视图消失的时候, 将系统导航恢复
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    IQKeyboardManager * manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self getMyAddressData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(238, 238, 238, 1);
    self.navItem.title = @"选择收货地址";
    self.rightButtonTitle = @"新增地址";
    self.results = [NSMutableArray array];
    [self.view addSubview:self.tableView];

    [self showNavBarItemRight];
    
    [self locationBtnAction];
    
    IQKeyboardManager * manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = NO;
    [self setSearchFrame];
    
    
    
}
-(void)setSearchFrame{
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    // 设置结果更新代理
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    // self.searchController.dimsBackgroundDuringPresentation = NO;
    
    
    //提醒字眼
    self.searchController.searchBar.placeholder= @"请输入地址关键字搜索";
    [self.searchController.searchBar sizeToFit];
    
    self.searchController.searchBar.searchBarStyle =UISearchBarStyleMinimal;
    //设置文本框背景
    [self.searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchBgView"] forState:UIControlStateNormal];
    self.searchController.searchBar.barTintColor = RGB(238, 238, 238, 1); // 设置背景颜色
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(0, kBarHeight, kWidth, searchBgViewHeight)];
    self.customView.backgroundColor = RGB(238, 238, 238, 1);
    [self.view addSubview:self.customView];
    
    [self.customView addSubview:self.searchController.searchBar];
    
    
    
    
    
    
}

#pragma mark = 收货地址列表

-(void)getMyAddressData{
    
    NSMutableDictionary *dic = [self checkoutData];
    self.myAddressArray = [NSMutableArray array];
    [self.myAddressArray removeAllObjects];
    [dic setValue:mTypeIOS forKey:@"mtype"];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [dic setValue:[user valueForKey:@"appVersionNumber"] forKey:@"appVersionNumber"];
    [dic setValue:[user valueForKey:@"user"] forKey:@"user"];
    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@/m/auth/shipping/list" ,baseUrl] params:dic successBlock:^(NSDictionary *returnData) {
        if ([[returnData[@"status"] stringValue] isEqualToString:@"200"]) {
            for (NSDictionary *dic in returnData[@"data"]) {
                MyAddressModel *addressModel = [MyAddressModel yy_modelWithJSON:dic];
                [self.myAddressArray addObject:addressModel];
            }
        }
        if ([returnData[@"code"] isEqualToString:@"0404"]) {
            [self.myAddressArray removeAllObjects];
        }

        [self.tableView reloadData];
        
        
    } failureBlock:^(NSError *error) {
        [self.view addSubview:self.tableView];

        
    } showHUD:NO];
 
}

#pragma mark = 新增地址

-(void)rightItemAction{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user valueForKey:@"isLoginState"]) {
        [GlobalHelper shareInstance].isLoginState = [user valueForKey:@"isLoginState"];
    }
    if ([[GlobalHelper shareInstance].isLoginState isEqualToString:@"1"])
    {
        AddNewAddressViewController *VC = [AddNewAddressViewController new];
        VC.isCanRemove = YES;
        VC.navTitle = @"新增收货地址";
        [self.navigationController pushViewController:VC animated:YES];
        
    
    }else
    {   
        
        LoginViewController *VC = [LoginViewController new];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}




-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kBarHeight+searchBgViewHeight, kWidth, kHeight-kBarHeight-searchBgViewHeight-LL_TabbarSafeBottomMargin) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.backgroundColor = RGB(238, 238, 238, 1);
    }
    return _tableView;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.searchController.active) {
        
        return 1 ;
        
    }else{

        if (self.myAddressArray.count == 0) {
            
             return 2;
        }
        
         return 3;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    // 这里通过searchController的active属性来区分展示数据源是哪个
    if (self.searchController.active) {
        
        return self.results.count ;
    }else{
    
    
    if (self.myAddressArray.count == 0) {
        if (section == 0) {
            return 1;
        }else{
            return self.otherAddressArray.count;
        }
    }else{
        if (section == 0) {
            return 1;
            }else if (section == 1){
                return self.myAddressArray.count;
              }else{
                  return self.otherAddressArray.count;
             }
    }
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.searchController.active) {
        return 60*kScale;
    }else{
    if (self.myAddressArray.count!=0) {
        
        if (indexPath.section == 1) {
            return 75*kScale;
        }
        return 60*kScale;
    }
    return 60*kScale;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        return 0.01;
        
    }
    return 35;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.searchController.active) {
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 0.01)];

        return view;
    }else{
    NSArray *titleArray = @[@"因各地区商品和配送服务不同,请你选择准确收货地址",@"我的收货地址",@"附近地址"];
    if (self.myAddressArray.count == 0) {
        titleArray = @[@"因各地区商品和配送服务不同,请你选择准确收货地址",@"附近地址"];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 15)];
    view.backgroundColor = RGB(238, 238, 238, 1);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kWidth-15, 35)];
    label.text = titleArray[section];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = RGB(138, 138, 138, 1);
    [view addSubview:label];
    return view;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 15)];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 这里通过searchController的active属性来区分展示数据源是哪个
    if (self.searchController.active) {
        
        NSString * Identifier = @"cell_search";
        SearchLocationAddressTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell1 == nil) {
            cell1 = [[SearchLocationAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            
            //[cell1 setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
            cell1.backgroundColor = [UIColor whiteColor];
            
        }
        
        
        if (self.results.count!=0) {
            Location *model =self.results[indexPath.row];
            cell1.addressDetailLab.text = model.name;
            if (model.administrativeArea == model.city) {
                model.administrativeArea = @"";
            }
            cell1.addressLab.text = [NSString stringWithFormat:@"%@%@%@%@" , model.administrativeArea ,model.city , model.subLocality ,model.thoroughfare];

        }
        
        return cell1;
    } else{
        NSString * Identifier = [NSString stringWithFormat:@"cell_%ld%ld",(long)indexPath.section,(long)indexPath.row];
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            
            [cell1 setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
            cell1.backgroundColor = [UIColor whiteColor];
            
        }
  
    if (indexPath.section == 0) {
        
        [[GlobalHelper shareInstance] openLocationServiceWithBlock:^(BOOL isOpen) {
            [cell1 addSubview:self.currentAddressView];
            if (isOpen == YES) {
                [self.currentAddressView setCurrentLabelTitle:self.currentLocation.name];
                self.currentAddressView.placeholderLab.text = @"当前位置";
            }else{
                [self.currentAddressView setCurrentLabelTitle:@"请在设置-隐私中打开定位服务权限"];
                self.currentAddressView.placeholderLab.text = @" ";
            }
            
        }];
       
    
    }
    if (self.myAddressArray.count == 0) {///我的收货地址不存在
        if (indexPath.section == 1){
            
//            Location *locat = self.otherAddressArray[indexPath.row];
//            cell1.textLabel.text = locat.name ;
            NSString * Identifier = @"otherAddresss_cell";
            SearchLocationAddressTableViewCell *myAddressCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (myAddressCell == nil) {
                myAddressCell = [[SearchLocationAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                
                [myAddressCell setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
                myAddressCell.backgroundColor = [UIColor whiteColor];
                
            }
            
            Location *model = self.otherAddressArray[indexPath.row];
            myAddressCell.addressDetailLab.text = model.name;
            if (model.administrativeArea == model.city) {
                model.administrativeArea = @"";
            }
            myAddressCell.addressLab.text = [NSString stringWithFormat:@"%@%@%@%@" , model.administrativeArea ,model.city , model.subLocality ,model.thoroughfare];
            
            return myAddressCell;
        }
        
    }else{///我的收货地址存在
        
        
        if (indexPath.section == 1){
            
            NSString * Identifier = @"myAddresss_cell";
            MyAddressTableViewCell *myAddressCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (myAddressCell == nil) {
                myAddressCell = [[MyAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                
                [myAddressCell setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
                myAddressCell.backgroundColor = [UIColor whiteColor];
                
            }
            
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
          
           
            
            if (self.myAddressArray.count != 0) {
                MyAddressModel *model = self.myAddressArray[indexPath.row];

                [myAddressCell setConfigAddressInfo:model isEdit:NO fromConfirmVC:@"0"];

            }
           
            return myAddressCell;
        
        }else if (indexPath.section == 2){
            
            
            NSString * Identifier = @"otherAddresss_cell";
            SearchLocationAddressTableViewCell *myAddressCell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (myAddressCell == nil) {
                myAddressCell = [[SearchLocationAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                
                [myAddressCell setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
                myAddressCell.backgroundColor = [UIColor whiteColor];
                
            }
            
            Location *model = self.otherAddressArray[indexPath.row];
            myAddressCell.addressDetailLab.text = model.name;
            if (model.administrativeArea == model.city) {
                model.administrativeArea = @"";
            }
            myAddressCell.addressLab.text = [NSString stringWithFormat:@"%@%@%@%@" , model.administrativeArea ,model.city , model.subLocality ,model.thoroughfare];
            
            return myAddressCell;
          
        }
        
        
        
    }
        return cell1;

    }
   
    
}

#pragma mark  = 点击事件


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.searchController.active) {
        if (self.results.count!=0) {
            Location *location =self.results[indexPath.row];
            if ([self respondsToSelector:@selector(selectAddressBL)]) {
                self.selectAddressBL(location);
            }
            
            [self searchBarCancelButtonClicked:self.searchController.searchBar];
            [self.navigationController popViewControllerAnimated:YES];
        }
       
    } else{
    
        if (indexPath.section == 0) {
            if ([self respondsToSelector:@selector(selectAddressBL)]) {
                self.selectAddressBL(self.currentLocation);
            }
            
        }
        if (self.myAddressArray.count == 0) {
            if (indexPath.section == 1){
                Location *locat = self.otherAddressArray[indexPath.row];

                if ([self respondsToSelector:@selector(selectAddressBL)]) {
                    self.selectAddressBL(locat);
                }
            }
            
        }else{
            
            
            if (indexPath.section == 1){
                
                MyAddressModel *model = self.myAddressArray[indexPath.row];
                
                Location *locat = [Location new];
                locat.city = model.receiverProvince;
                locat.subLocality = model.receiverProvince;
                
                NSArray *array = [model.receiverProvince componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组
                
                locat.name = [array lastObject];
//                    self.currentLocation.name = @"我的收获地址";
                if ([self respondsToSelector:@selector(selectAddressBL)]) {
                        self.selectAddressBL(locat);
                    }
                   
            
                
            }else if (indexPath.section == 2){

                Location *locat = self.otherAddressArray[indexPath.row];
                if ([self respondsToSelector:@selector(selectAddressBL)]) {
                    self.selectAddressBL(locat);
                }
               // cell1.textLabel.text = self.otherAddressArray[indexPath.row];
                
            }
            
        }
        
        [self.navigationController popViewControllerAnimated:YES];

    }
  
   
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text ;

    [[DDSearchManager sharedManager] keyWordsSearch:inputStr city:@"" returnBlock:^(NSArray<__kindof DDSearchPointAnnotation *> *pointAnnotaions) {
        if (self.results.count > 0) {
            [self.results removeAllObjects];
        }
        
        for (DDSearchPointAnnotation *poi in pointAnnotaions) {
            Location *locat = [Location new];
            
            locat.administrativeArea = poi.province;
            locat.city = poi.city;
            locat.subLocality = poi.district;
            locat.longitude = poi.coordinate.longitude;
            locat.latitude = poi.coordinate.latitude;
            locat.name = poi.name;
            locat.thoroughfare = poi.address;
            
            [self.results addObject:locat];

        }
        [self.tableView reloadData];

    }];

}


#pragma mark - UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarState = @"搜索";
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

    CGRect barFrame = self.customView.frame;
    // 恢复
    barFrame.origin.y = kBarHeight;
    barFrame.size.height= searchBgViewHeight;
    // 调整tableView的frame为全屏
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = kBarHeight+searchBgViewHeight;
    tableFrame.size.height = self.view.frame.size.height - kBarHeight-searchBgViewHeight-LL_TabbarSafeBottomMargin;
    
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.customView.frame = barFrame;
        self.tableView.frame = tableFrame;
    }];

    
    self.searchBarState = @"取消";
    [self.results removeAllObjects];
    self.searchController.active = NO;
    [self.tableView reloadData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.active = YES;
    CGRect barFrame = self.customView.frame;
    // 移动到屏幕上方
    barFrame.origin.y = 0;
    barFrame.size.height= kBarHeight;
    // 调整tableView的frame为全屏
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = kBarHeight;
    tableFrame.size.height = self.view.frame.size.height -kBarHeight-LL_TabbarSafeBottomMargin;
   
    self.customView.frame = barFrame;
    self.tableView.frame = tableFrame;
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view layoutIfNeeded];
        [self.tableView layoutIfNeeded];
    }];
    [self.tableView reloadData];
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    if ([self.searchBarState isEqualToString:@"搜索" ]) {
        
        CGRect rect = self.customView.frame;
        rect.size.height = searchBgViewHeight;
        self.customView.frame = rect;
        //调整tableView的frame为全屏
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y = kBarHeight;
        tableFrame.size.height = self.view.frame.size.height - kBarHeight;
        self.tableView.frame = tableFrame;
        [self.tableView layoutIfNeeded];
        
    }else{
        
        CGRect barFrame = self.customView.frame;
        // 恢复
        barFrame.origin.y = kBarHeight;
        barFrame.size.height= searchBgViewHeight;
        // 调整tableView的frame为全屏
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y = kBarHeight+searchBgViewHeight;
        tableFrame.size.height = self.view.frame.size.height - kBarHeight-searchBgViewHeight-LL_TabbarSafeBottomMargin;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            self.customView.frame = barFrame;
            self.tableView.frame = tableFrame;
        }];
        
    }
    
}
//
//-(MyAddressView*)myAddressView{
//    if (!_myAddressView) {
//        _myAddressView = [[MyAddressView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 75)];
//    }
//    
//    return _myAddressView;
//}


-(CurrentAddressView*)currentAddressView{
    if (!_currentAddressView) {
        _currentAddressView = [[CurrentAddressView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 45)];
        [_currentAddressView.locationBtn addTarget:self action:@selector(loadCurrentAddress) forControlEvents:1];
    }
    return _currentAddressView;
}

-(void)loadCurrentAddress{
    
    [[GlobalHelper shareInstance] openLocationServiceWithBlock:^(BOOL isOpen) {
        if (isOpen == YES) {
            [self rotateImageViews];
            [self locationBtnAction];
        }else{
            [self stopAnimation];
            
        }
    }];
    
}

#pragma mark =定位点击事件

-(void)locationBtnAction{
    [self setLocations];
}

- (void)rotateImageViews {
    // 一秒钟旋转几圈
    CGFloat circleByOneSecond = 4.f;
    
    // 执行动画
    [UIView animateWithDuration:1.f / circleByOneSecond
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.currentAddressView.locationBtn.transform =CGAffineTransformRotate(self.currentAddressView.locationBtn.transform, M_PI_2);
                     }
                     completion:^(BOOL finished){
                         if (_isFinishedAnimation) {
                             [self stopAnimation];
                         }
                         else{
                             [self rotateImageViews];

                         }
                     }];
}

-(void)stopAnimation{
    [self.currentAddressView.locationBtn.layer removeAllAnimations];

}

#pragma mark = 定位

-(void)setLocations{
    self.rhLocation = [[RHLocation alloc] init];
    self.rhLocation.delegate = self;
    [self.rhLocation beginUpdatingLocation];
}

- (void)locationDidEndUpdatingLocation:(Location *)location{
    
    self.currentAddressSubLocality = location.subLocality;
    self.currentLocation = location;
    [self getAddresspoiWithLocation:location];
    
    _isFinishedAnimation = YES;
}

-(void)getAddresspoiWithLocation:(Location*)location{
   
    //逆地理编码，请求附近兴趣点数据
    [[DDSearchManager sharedManager] poiReGeocode:CLLocationCoordinate2DMake(location.latitude,location.longitude) returnBlock:^(NSArray<__kindof DDSearchPoi *> *pois) {
        
        self.otherAddressArray = [NSMutableArray array];
        [self.otherAddressArray removeAllObjects];
        for (DDSearchPoi *poi in pois) {
            poi.district = self.currentAddressSubLocality;
            Location *locat = [Location new];
            
            locat.administrativeArea = self.currentLocation.administrativeArea;
            locat.city = self.currentLocation.city;
            locat.thoroughfare = poi.address;

            locat.subLocality = poi.district;
            locat.longitude = poi.coordinate.longitude;
            locat.latitude = poi.coordinate.latitude;
            locat.name = poi.name;

            
            if (![self.otherAddressArray containsObject:locat]) {
                [self.otherAddressArray addObject:locat];
            }
            
        }
        [self.tableView reloadData];

    }];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
