//
//  RZAutoScrollTextField.h
//  RZAutoScrollField
//
//  Created by rizhao_zhang on 02/09/2017.
//  Copyright © 2017 rizhao_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RZAutoScrollTextField : UITextField

@property (nonatomic, assign) BOOL autoScrollToField;//default is true
@property (nonatomic, weak) UIScrollView* mainScrollView;//default is to find tableview
@property (nonatomic, weak) UIView* scrollToField;//default is to scroll to self
@property (nonatomic, assign) CGFloat offsetY;//default is 66,默认滚完后的增加偏移量
@property (nonatomic, assign) UIEdgeInsets textFieldInset;

@end
