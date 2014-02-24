//
//  FMViewController.m
//  FMGrowingTextViewExample
//
//  Created by Fernando Mazzon on 2/21/14.
//  Copyright (c) 2014 Fernando Mazzon. All rights reserved.
//

#import "FMViewController.h"
#import <FMGrowingTextView/FMGrowingTextView.h>

@interface FMViewController ()

@property (strong, nonatomic) IBOutlet FMGrowingTextView *textView;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardBottomConstraint;

@end

@implementation FMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Custom look
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.textView endEditing:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    CGRect _keyboardBeginFrame;
    [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&_keyboardBeginFrame];
    CGRect _keyboardEndFrame;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    
    NSTimeInterval _animationDuration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger _animationCurve = [[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:_animationDuration
                          delay:0.0
                        options:_animationCurve
                     animations:^{
                         self.keyboardBottomConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    CGRect _keyboardBeginFrame;
    [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&_keyboardBeginFrame];
    CGRect _keyboardEndFrame;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    
    NSTimeInterval _animationDuration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger _animationCurve = [[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:_animationDuration
                          delay:0.0
                        options:_animationCurve
                     animations:^{
                         self.keyboardBottomConstraint.constant = _keyboardEndFrame.size.height;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (IBAction)buttonAction:(id)sender
{
    self.textView.text = nil;
}

- (IBAction)changeConstraints:(id)sender
{
    [UIView animateWithDuration:self.textView.animationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.textView.viewToLayout setNeedsLayout];
                         [self.textView.viewToLayout layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
