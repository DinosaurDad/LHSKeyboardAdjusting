//
//  UIViewController+LHSKeyboardAdjustment.m
//  LHSKeyboardAdjusting
//
//  Created by Dan Loewenherz on 3/18/14.
//  Copyright (c) 2014 Lionheart Software LLC. All rights reserved.
//

#import "UIViewController+LHSKeyboardAdjustment.h"

@implementation UIViewController (LHSKeyboardAdjustment)

- (void)lhs_activateKeyboardAdjustment {
    [self lhs_activateKeyboardAdjustmentWithShow:nil hide:nil];
}

- (void)lhs_activateKeyboardAdjustmentWithShow:(LHSKeyboardAdjustingBlock)show hide:(LHSKeyboardAdjustingBlock)hide {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lhs_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:hide];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lhs_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:show];
}

- (void)lhs_deactivateKeyboardAdjustment {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)lhs_keyboardWillHide:(NSNotification *)sender {
    BOOL enabled = [self respondsToSelector:@selector(keyboardAdjustingBottomConstraint)];
    NSAssert(enabled, @"keyboardAdjustingBottomConstraint must be implemented to enable automatic keyboard adjustment.");
    
    if (enabled) {
        LHSKeyboardAdjustingBlock block = sender.object;
        if (block) {
            block();
        }
        
        NSDictionary *userInfo = sender.userInfo;
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = (UIViewAnimationCurve) [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

        
        self.keyboardAdjustingBottomConstraint.constant = 0;
        if(self.keyboardAdjustingAnimated) {
            __weak UIViewController *weakSelf = self;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
                [weakSelf.view layoutIfNeeded];
            } completion:nil];
        }
        else
        {
        [self.view layoutIfNeeded];
    }
    }
}

- (void)lhs_keyboardWillShow:(NSNotification *)sender {
    BOOL enabled = [self respondsToSelector:@selector(keyboardAdjustingBottomConstraint)];
    NSAssert(enabled, @"keyboardAdjustingBottomConstraint must be implemented to enable automatic keyboard adjustment.");
    
    if (enabled) {
        LHSKeyboardAdjustingBlock block = sender.object;
        if (block) {
            block();
        }
        
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        self.keyboardAdjustingBottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);

        NSDictionary *userInfo = sender.userInfo;
        NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = (UIViewAnimationCurve) [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

        if(self.keyboardAdjustingAnimated) {
            __weak UIViewController *weakSelf = self;
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
                [weakSelf.view layoutIfNeeded];
            } completion:nil];
        }
        else
        {
            [self.view layoutIfNeeded];
        }
    }
}

- (NSLayoutConstraint *)keyboardAdjustingBottomConstraint {

    [NSException raise:NSInternalInconsistencyException format:@"'%@' must override -keyboardAdjustingBottomConstraint", NSStringFromClass(self.class)];

    return nil;
}

- (BOOL)keyboardAdjustingAnimated
{
    return NO; // don't animate by default
}

@end
