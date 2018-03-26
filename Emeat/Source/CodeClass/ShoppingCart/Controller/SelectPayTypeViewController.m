//
//  SelectPayTypeViewController.m
//  Emeat
//
//  Created by liuheshun on 2017/12/8.
//  Copyright © 2017年 liuheshun. All rights reserved.
//

#import "SelectPayTypeViewController.h"
#import "ConfirmOrderInfoPayTypeTableViewCell.h"
#import "OrderDetailesViewController.h"
@interface SelectPayTypeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
//单选，当前选中的行
@property (assign, nonatomic) NSIndexPath *selIndex;
//底部view
@property (nonatomic,strong) UIButton *bottomPayBtn;
//当前选择的支付方式
@property (nonatomic,strong) NSString *selectPayType;


@end

@implementation SelectPayTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(238, 238, 238, 1);
    self.navItem.title = @"选择支付方式";
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomPayBtn];
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}


-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kBarHeight, kWidth, kHeight-kBarHeight -44-LL_TabbarSafeBottomMargin ) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return 15;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 15)];
    view.backgroundColor = RGB(238, 238, 238, 1);
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 15)];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ConfirmOrderInfoPayTypeTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"list_cell_pay"];
    if (cell1 == nil) {
        cell1 = [[ConfirmOrderInfoPayTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"list_cell_pay"];
        
        //[cell1 setSelectionStyle:UITableViewCellSelectionStyleNone]; //取消选中的阴影效果
        cell1.backgroundColor = [UIColor whiteColor];
        
    }
    NSArray*array = @[@"支付宝支付" ,@"微信支付" ,@"银行卡快捷支付" ,@"其它方式"];
    NSArray *iconArray = @[@"zhifubao" ,@"weixin" ,@"yinlian" ,@"qitazhifu"];
    [cell1.payTypeBtn setTitle:array[indexPath.row] forState:0];
    [cell1.payTypeBtn setImage:[UIImage imageNamed:iconArray[indexPath.row]] forState:0];
    cell1.payTypeBtn.userInteractionEnabled = NO;
    cell1.roundPayBtn.userInteractionEnabled = NO;
    
    if (_selIndex == indexPath) {
        [cell1.roundPayBtn setImage:[UIImage imageNamed:@"selected"] forState:0];
    }else {
        [cell1.roundPayBtn setImage:[UIImage imageNamed:@"no_selected"] forState:0];
    }
    
    return cell1;
}

#pragma mark  = 点击事件


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //隐藏tabBar
    //之前选中的，取消选择
    ConfirmOrderInfoPayTypeTableViewCell *celled = [tableView cellForRowAtIndexPath:_selIndex];
    [celled.roundPayBtn setImage:[UIImage imageNamed:@"no_selected"] forState:0];
    //记录当前选中的位置索引
    _selIndex = indexPath;
    //当前选择的打勾
    ConfirmOrderInfoPayTypeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.roundPayBtn setImage:[UIImage imageNamed:@"selected"] forState:0];

    switch (indexPath.row) {
        case 0:{
            DLog(@"支付宝");
            self.selectPayType = @"0";
        }
            break;
            
        case 1:{
            DLog(@"微信");
            self.selectPayType = @"1";

        }
            break;
            
        case 2:{
            DLog(@"银联");
            self.selectPayType = @"2";

        }
            break;
            
        case 3:{
            DLog(@"其它");
            self.selectPayType = @"11";

        }
            break;
            
        default:
            break;
    }
}



-(UIButton *)bottomPayBtn{
    if (!_bottomPayBtn) {
        _bottomPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomPayBtn.frame = CGRectMake(0, kHeight-44 - LL_TabbarSafeBottomMargin, kWidth, 44);
        _bottomPayBtn.backgroundColor = RGB(231, 31, 35, 1);
        [_bottomPayBtn addTarget:self action:@selector(bottomPayBtnAction) forControlEvents:1];
        [_bottomPayBtn setTitle:@"确定支付" forState:0];
    }
    return _bottomPayBtn;
}

-(void)bottomPayBtnAction{
    DLog(@"立即支付");
    if ([self.selectPayType isEqualToString:@"0"]) {
        DLog(@"调用支付宝支付");

    }else if ([self.selectPayType isEqualToString:@"1"]){
        DLog(@"调用微信支付");
        if (![WXApi isWXAppInstalled]) {
            [SVProgressHUD dismiss];
            
            [self alertMessage:@"未安装微信客户端" willDo:nil];
        }else{
            //注册通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePayResult:) name:@"WX_PAY_RESULT" object:nil];
            //调起支付
            [SVProgressHUD dismiss];
            
            [self sendWXpay];
        }
        
        
    }else if ([self.selectPayType isEqualToString:@"2"]){
        DLog(@"yinhangka");

    }else if ([self.selectPayType isEqualToString:@"11"]){
        DLog(@"qitafangshi");
        [self requsetOtherPayTypes];
        [SVProgressHUD show];

    }
}


#pragma mark == 周期性付款

-(void)requsetOtherPayTypes{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ticket = [user valueForKey:@"ticket"];
    NSString *secret = @"UHnyKzP5sNmh2EV0Dflgl4VfzbaWc4crQ7JElfw1cuNCbcJUau";
    NSString *nonce = [self ret32bitString];//随机数
    NSString *curTime = [self dateTransformToTimeSp];
    NSString *checkSum = [self sha1:[NSString stringWithFormat:@"%@%@%@" ,secret ,  nonce ,curTime]];
    
    [dic setObject:secret forKey:@"secret"];
    [dic setObject:nonce forKey:@"nonce"];
    [dic setObject:curTime forKey:@"curTime"];
    [dic setObject:checkSum forKey:@"checkSum"];
    [dic setObject:ticket forKey:@"ticket"];
    [dic setValue:self.orderNo forKey:@"orderNo"];
    [dic setValue:self.selectPayType forKey:@"payId"];
    [dic setValue:@" " forKey:@"bankType"];
    [dic setValue:@" " forKey:@"transactionType"];

    DLog(@"周期性付款====== dic == %@ %@ %@ " ,dic , self.orderNo ,self.selectPayType );

    [MHNetworkManager postReqeustWithURL:[NSString stringWithFormat:@"%@/auth/payInfo/pay" , baseUrl] params:dic successBlock:^(NSDictionary *returnData) {
        DLog(@"周期性付款信息===msg=  %@   returnData == %@" ,returnData[@"msg"] , returnData);

        if ([returnData[@"status"] integerValue] == 200)
        {
            [SVProgressHUD dismiss];
            OrderDetailesViewController *VC = [OrderDetailesViewController new];
            VC.orderNo = self.orderNo;
            VC.fromVC = @"1";
            DLog(@"订单号===== %@" ,self.orderNo);
            [self.navigationController pushViewController:VC animated:YES];
            
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:returnData[@"msg"]];
        }

//
//            NSString *productTotalPrice = returnData[@"data"][@"productTotalPrice"];
//
//            for (NSMutableDictionary *dic in returnData[@"data"][@"orderItemVoList"]) {
//
//                ShoppingCartModel *model = [ShoppingCartModel yy_modelWithJSON:dic];
//                model.productTotalPrice = [productTotalPrice integerValue];
//                [orderListMarray addObject:model];
//            }
//
//            [SVProgressHUD dismiss];
////            ConfirmOrderInfoViewController *VC = [ConfirmOrderInfoViewController new];
////            VC.hidesBottomBarWhenPushed = YES;
////            VC.orderListMarray = orderListMarray;
////            [self.navigationController pushViewController:VC animated:YES];
//            NSLog(@"去结算");
//        }
//        else
//        {
//            [SVProgressHUD showErrorWithStatus:returnData[@"msg"]];
//        }
    } failureBlock:^(NSError *error) {
        DLog(@"获取订单信息err0r=== %@  " ,error);
        [SVProgressHUD dismiss];
    } showHUD:NO];
    
}



-(void)sendWXpay{
    
    
    NSDictionary *dic;
    
    
    [[LHSPayManger sharedManager] sendWXPay:dic];

    
}




- (void)handlePayResult:(NSNotification *)noti{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"支付结果" message:[NSString stringWithFormat:@"%@",noti.object] preferredStyle:UIAlertControllerStyleActionSheet];
    if ([noti.object isEqualToString:@"成功"]) {
        
//        GHDetailsViewController *VC = [GHDetailsViewController new];
//        [WMLoginHelper shareInstance].isHadSignUp = YES;
//        [self presentViewController:VC animated:YES completion:nil];
//
        // [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        //添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"重新支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           // [self commitBtnAction];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
    }
    [self presentViewController:alert animated:YES completion:nil];
    //上边添加了监听，这里记得移除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weixin_pay_result" object:nil];
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