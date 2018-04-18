//
//  MyOrderDetailsStatusHeadView.h
//  Emeat
//
//  Created by liuheshun on 2017/12/14.
//  Copyright © 2017年 liuheshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrderDetailsStatusAccountHeadView.h"

@interface MyOrderDetailsStatusHeadView : UIView
///周期性用户view
@property (nonatomic,strong) MyOrderDetailsStatusAccountHeadView  *myOrderDetailsStatusAccountHeadView;



//订单状态
//背景
@property (nonatomic,strong) UIImageView *statusBgImv;
//订单状态
@property (nonatomic,strong) UILabel *orderStatusLab;
//订单状态详情
@property (nonatomic,strong) UILabel *orderStatusDetailsLab;
//图标
@property (nonatomic,strong) UIButton *statusImv;


//配送信息
@property (nonatomic,strong) UIView *sendBgView;
@property (nonatomic,strong) UILabel *sendInfoLab;
@property (nonatomic,strong) UILabel *sendAddressLab;
@property (nonatomic,strong) UILabel *orderNameLab;
@property (nonatomic,strong) UILabel *orderPhoneNumerLab;
@property (nonatomic,strong) UILabel *orderAddressLab;
///备注信息
@property (nonatomic,strong) UIView *orderCommentBgView;
///备注信息
@property (nonatomic,strong) UILabel *orderCommentLab;
///备注信息
@property (nonatomic,strong) UILabel *orderCommentDetailsLab;




//商品信息标签
@property (nonatomic,strong) UIView *goodsBgView;
@property (nonatomic,strong) UILabel *goodsLab;



-(void)configAddressWithModel:(MyAddressModel*)addressModel orderModel:(OrderModel*)orderModel;

















@end
