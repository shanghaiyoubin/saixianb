//
//  HomePageSortListTableViewCell.m
//  Emeat
//
//  Created by liuheshun on 2018/8/3.
//  Copyright © 2018年 liuheshun. All rights reserved.
//

#import "HomePageSortListTableViewCell.h"

@implementation HomePageSortListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.mainImv];
        [self addSubview:self.lableBtn];
        [self addSubview:self.nameLab];
        [self addSubview:self.descLab];
        [self addSubview:self.weightLab];
        [self addSubview:self.newsPriceBtn];
        [self addSubview:self.oldPriceBtn];
        [self addSubview:self.cartBtn];
        [self setMainViewFrame];
        
        
    }
    return self;
}

-(void)configCellWithModel:(HomePageModel *)model{
    
    [self.mainImv sd_setImageWithURL:[NSURL URLWithString:model.mainImage] placeholderImage:[UIImage imageNamed:@"列表图加载"]];
    
    self.nameLab.text = model.commodityName;
    self.descLab.text = model.commodityDesc;
    
//    CGFloat hDesc =   [GetWidthAndHeightOfString getHeightForText:self.descLab width:kWidth -(115+21+21+15)*kScale];
//
//    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(hDesc));
//    }];
    
    
    self.weightLab.text = model.size;
    
   
    
//    self.newsPriceBtn.backgroundColor = [UIColor cyanColor];
//    self.oldPriceBtn.backgroundColor = [UIColor cyanColor];
    
   
    
    
    if ([model.goodsTypes isEqualToString:@"1"]) {//商户专区
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        if ([[user valueForKey:@"approve"] isEqualToString:@"1"]) {
            ///商户认证通过可看到价格可购买
            
            if ([model.priceTypes isEqualToString:@"WEIGHT"]) {
                if (model.discountPrice == -1) {///只显示原价
                    
                    [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/kg",(float)model.costPrice/100] forState:0];
                    
                    [self.oldPriceBtn setTitle:@"" forState:0];
                    self.oldPriceBtn.hidden = YES;
                    
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f元/kg",(float)model.costPrice/100]];
                    NSRange range1 = [[str string] rangeOfString:[NSString stringWithFormat:@"%.2f" ,(float)model.costPrice/100]];
                    
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(236, 31, 35, 1) range:range1];
                    
                    NSRange range2 = [[str string] rangeOfString:@"元/kg"];
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(136, 136, 136, 1) range:range2];

                    [self.newsPriceBtn setAttributedTitle:str forState:UIControlStateNormal];

                    
                    //
                    
                    
                    
                    
                    
                }else{
                    self.oldPriceBtn.hidden = NO;

                    [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/kg",(float)model.unitPrice/100] forState:0];
                    [self.oldPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/kg",(float)model.costPrice/100] forState:0];
                    
                    
                    
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f元/kg",(float)model.unitPrice/100]];
                    NSRange range1 = [[str string] rangeOfString:[NSString stringWithFormat:@"%.2f" ,(float)model.unitPrice/100]];
                    
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(236, 31, 35, 1) range:range1];
                    
                    NSRange range2 = [[str string] rangeOfString:@"元/kg"];
                    [str addAttribute:NSForegroundColorAttributeName value:RGB(136, 136, 136, 1) range:range2];
                    
                    [self.newsPriceBtn setAttributedTitle:str forState:UIControlStateNormal];
                    
                    
                    
                    
                    
                }
                
            }else{
                if (model.discountPrice == -1) {///只显示原价
                    
                    [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/件",(float)model.costPrice/100] forState:0];
                    [self.oldPriceBtn setTitle:@"" forState:0];
                    self.oldPriceBtn.hidden = YES;

                }else{
                    self.oldPriceBtn.hidden = NO;

                    [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/件",(float)model.unitPrice/100] forState:0];
                    [self.oldPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元/件",(float)model.costPrice/100] forState:0];
                    
                }
                
            }

           
            
        }else if ([[user valueForKey:@"approve"] isEqualToString:@"0"] || [[user valueForKey:@"approve"] isEqualToString:@"2"]){
            
            if (model.discountPrice == -1) {///只显示原价
                
                [self.newsPriceBtn setTitleColor:RGB(231, 35, 36, 1) forState:0];
                [self.newsPriceBtn setTitle:@"查看价格" forState:0];
                [self.oldPriceBtn setTitle:@"" forState:0];
                self.oldPriceBtn.hidden = YES;

            }else{
                ///商户未认证或者认证未通过
                self.oldPriceBtn.hidden = NO;

                [self.newsPriceBtn setTitleColor:RGB(231, 35, 36, 1) forState:0];
                [self.newsPriceBtn setTitle:@"查看价格" forState:0];
                [self.oldPriceBtn setTitle:@"原价" forState:0];
                
            }
            
        }
        
        
    }else if ([model.goodsTypes isEqualToString:@"0"]){
        if (model.discountPrice == -1) {///只显示原价
            
            [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元",(float)model.costPrice/100] forState:0];
            [self.oldPriceBtn setTitle:@"" forState:0];
            self.oldPriceBtn.hidden = YES;


        }else{
            self.oldPriceBtn.hidden = NO;

            [self.newsPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元",(float)model.unitPrice/100] forState:0];
            [self.oldPriceBtn setTitle:[NSString stringWithFormat:@"%.2f元",(float)model.costPrice/100] forState:0];
            
        }
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.newsPriceBtn.titleLabel.text];
        NSRange range1 = [[str string] rangeOfString:[NSString stringWithFormat:@"%.2f元" ,(float)model.unitPrice/100]];
        [str addAttribute:NSForegroundColorAttributeName value:RGB(236, 31, 35, 1) range:range1];
        
        
        [self.newsPriceBtn setAttributedTitle:str forState:UIControlStateNormal];
        
    }
    
    
    [self.newsPriceBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@([self getOldPricesWidthText:self.newsPriceBtn Font:12.0f*kScale]));
    }];
    [self.oldPriceBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@([self getOldPricesWidthText:self.oldPriceBtn Font:11.0f*kScale]));
        
    }];
    
    
    UIView*lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 7*kScale, [self getOldPricesWidthText:self.oldPriceBtn Font:11.0f*kScale], 1)];
    lineView.backgroundColor = RGB(136, 136, 136, 1);
    if (model.discountPrice == -1) {///只显示原价
        [lineView removeFromSuperview];
    }else{
        [self.oldPriceBtn addSubview:lineView];
        
    }
    
    
    

    
    
    
    
    
    
    
    
    if ([model.commodityMark isEqualToString:@"热销"]) {
        [self.lableBtn setImage:[UIImage imageNamed:@"rexiao"] forState:0];
        
    }else if ([model.commodityMark isEqualToString:@"新品"]){
        [self.lableBtn setImage:[UIImage imageNamed:@"NEW"] forState:0];
        
    }else if ([model.commodityMark isEqualToString:@"特惠"]){
        [self.lableBtn setImage:[UIImage imageNamed:@"tehui"] forState:0];
        
    }else if ([model.commodityMark isEqualToString:@"试样"]){
        [self.lableBtn setImage:[UIImage imageNamed:@"试样"] forState:0];
        
    }
    else {
        [self.lableBtn setImage:[UIImage imageNamed:@"wu"] forState:0];
        
    }
    if (model.number) {
        self.cartView.numberLabel.text =[NSString stringWithFormat:@"%ld" ,model.number];
        
    }
    
    [self.cartBtn setImage:[UIImage imageNamed:@"join_cart"] forState:0];
    
  
    
}

#pragma mark ========计算原价宽度

-(CGFloat)getOldPricesWidthText:(UIButton*)button Font:(CGFloat)fonts{
    
    CGSize size=CGSizeMake(MAXFLOAT, 16*kScale);
    UIFont *font=[UIFont systemFontOfSize:fonts];
    NSDictionary *attrs=@{NSFontAttributeName:font};
    CGSize s=[button.titleLabel.text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine |
              
              NSStringDrawingUsesLineFragmentOrigin |
              
              NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
    
    return s.width+5*kScale;
    
}


-(AddOrCutShoppingCartView *)cartView{
    if (!_cartView) {
        _cartView = [[AddOrCutShoppingCartView alloc] init];
        
    }
    return _cartView;
}

-(void)setCartViewFrames{
    
    [self.cartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-15*kScale);
        make.bottom.equalTo(self.mainImv).with.offset(0);
        make.width.equalTo(@(100*kScale));
        make.height.equalTo(@(30*kScale));
    }];
}



-(UIButton*)lableBtn{
    if (!_lableBtn) {
        _lableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _lableBtn;
}

-(UIImageView*)mainImv{
    if (!_mainImv) {
        _mainImv = [[UIImageView alloc] init];
    }
    return _mainImv;
}


-(UILabel*)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:15.0f*kScale];
        _nameLab.textColor = RGB(51, 51, 51, 1);
        
    }
    return _nameLab;
}

-(UILabel*)descLab{
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont systemFontOfSize:12.0f*kScale];
        _descLab.numberOfLines = 1;
        _descLab.textColor = RGB(136, 136, 136, 1);
    }
    return _descLab;
}

-(UILabel*)weightLab{
    if (!_weightLab) {
        _weightLab = [[UILabel alloc] init];
        _weightLab.font = [UIFont systemFontOfSize:12.0f*kScale];
        _weightLab.textColor = RGB(136, 136, 136, 1);
    }
    return _weightLab;
}



-(UIButton*)newsPriceBtn{
    if (!_newsPriceBtn) {
        _newsPriceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _newsPriceBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f*kScale];
        [_newsPriceBtn setTitleColor:RGB(136, 136, 136, 1) forState:0];
        _newsPriceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _newsPriceBtn;
}


-(UIButton*)oldPriceBtn{
    if (!_oldPriceBtn) {
        _oldPriceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _oldPriceBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f*kScale];
        [_oldPriceBtn setTitleColor:RGB(136, 136, 136, 1) forState:0];
        _oldPriceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    return _oldPriceBtn;
}


-(UIButton*)cartBtn{
    if (!_cartBtn) {
        _cartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _cartBtn;
}







-(void)setMainViewFrame{
    
    [self.mainImv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10*kScale);
        make.top.equalTo(self.mas_top).with.offset(15*kScale);
        make.width.equalTo(@(80*kScale));
        make.height.equalTo(@(70*kScale));
    }];
    
    [self.lableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImv.mas_left).with.offset(-6*kScale);
        make.top.equalTo(self.mainImv.mas_top).with.offset(-10*kScale);
        make.height.equalTo(@(46*kScale));
        make.width.equalTo(@(31*kScale));
        
    }];
    
    
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImv.mas_right).with.offset(10*kScale);
        make.top.equalTo(self.mainImv.mas_top).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(-15*kScale);
        make.height.equalTo(@(16*kScale));
    }];
    
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImv.mas_right).with.offset(10*kScale);
        make.top.equalTo(self.nameLab.mas_bottom).with.offset(5*kScale);
        make.right.equalTo(self.mas_right).with.offset(-15*kScale);
        make.height.equalTo(@(13*kScale));
    }];
    
    [self.weightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImv.mas_right).with.offset(10*kScale);
        make.top.equalTo(self.descLab.mas_bottom).with.offset(5*kScale);
        make.right.equalTo(self.mas_right).with.offset(-15*kScale);
        make.height.equalTo(@(13*kScale));
    }];
    
   
    [self.newsPriceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainImv.mas_right).with.offset(10*kScale);
        make.bottom.equalTo(self.mainImv.mas_bottom).with.offset(0);
        make.width.equalTo(@(80*kScale));
        make.height.equalTo(@(16*kScale));
    }];
    
    
    [self.oldPriceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.newsPriceBtn.mas_right).with.offset(0*kScale);
        make.bottom.equalTo(self.mainImv.mas_bottom).with.offset(0);
        make.width.equalTo(@(80*kScale));
        make.height.equalTo(@(16*kScale));
    }];
    
    
    
    
    [self.cartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainImv.mas_bottom).with.offset(10*kScale);
        make.right.equalTo(self.mas_right).with.offset(-8*kScale);
        make.height.width.equalTo(@(40*kScale));
    }];
}





- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
