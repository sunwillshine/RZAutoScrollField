//
//  RZAutoScrollTextView.m
//  RZAutoScrollField
//
//  Created by rizhao_zhang on 02/09/2017.
//  Copyright © 2017 rizhao_zhang. All rights reserved.
//

#import "RZAutoScrollTextView.h"

@interface RZAutoScrollTextView()
{
    CGSize _keyboardSize;
    UIView* _editingTextField;
    CGPoint _contentOffset;
}

@end

@implementation RZAutoScrollTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupAutoScrollTextField];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setupAutoScrollTextField];
    }
    return self;
}

- (void)setupAutoScrollTextField {
    self.autoScrollToField = YES;
    self.offsetY = 66;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}

- (UITableView*)findTableViewFrom:(UIView*)view {
    if(view == nil) return nil;
    
    if([view isKindOfClass:[UITableView class]]) {
        return (UITableView*)view;
    } else {
        return [self findTableViewFrom:view.superview];
    }
}

#pragma mark - UITextField notifications

- (void)textFieldDidBeginEditing:(NSNotification *) notification
{
    UIView *textField = (UIView*)[notification object];
    _editingTextField = textField;
    
    if(self.autoScrollToField) {
        if(self.mainScrollView == nil) {
            //默认行为是寻找TableView
            self.mainScrollView = [self findTableViewFrom:self];
        } else {
            NSAssert2([self isDescendantOfView:self.mainScrollView], @"%@ is not DescendantOfView %@", self, self.mainScrollView);
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)textFieldDidEndEditing:(NSNotification *) notification
{
    _editingTextField = nil;
}

- (void)keyboardDidShow:(NSNotification *) notification
{
    if (_editingTextField == nil || _editingTextField != self) {
        _editingTextField = nil;
        return;
    }
    NSDictionary* info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField:(self.scrollToField?:self)];
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.mainScrollView setContentOffset:_contentOffset];
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)scrollToField:(UIView*)textField
{
    CGRect textRectInScreen = [textField convertRect:textField.bounds toView:textField.window];
    
    CGRect topRect = textField.window.bounds;
    topRect.size.height -= _keyboardSize.height + self.offsetY;
    
    _contentOffset = self.mainScrollView.contentOffset;
    if (!CGRectContainsPoint(topRect, textRectInScreen.origin)) {
        CGPoint scrollPoint = CGPointMake(0,self.mainScrollView.contentOffset.y + textRectInScreen.origin.y + textField.frame.size.height - topRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        [self.mainScrollView setContentOffset:scrollPoint animated:YES];
    }
}

@end
