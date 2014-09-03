//
//  FMGrowingTextView.m
//  FMGrowingTextView
//
//  Created by Fernando Mazzon on 2/21/14.
//  Copyright (c) 2014 Fernando Mazzon. All rights reserved.
//

#import "FMGrowingTextView.h"

@implementation FMGrowingTextView

#pragma mark - Construction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    //Initialize defaults
    if (!self.font) {
        self.font = [UIFont systemFontOfSize:14];
    }
    
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    
    [self setMinimumHeightWithNumberOfLines:1 animated:NO completion:^{}];
    [self setMaximumHeightWithNumberOfLines:4 animated:NO completion:^{}];
    
    self.animateTransitions = YES;
    self.animationDuration = 0.1;
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    
    if (!self.viewToLayout) {
        self.viewToLayout = self;
    }
}

#pragma mark - UITextView

- (void)setContentSize:(CGSize)contentSize
{
    CGSize formerIntrinsicContentSize = [self contentSize];
    [super setContentSize:CGSizeMake(contentSize.width, contentSize.height)];
    [self invalidateIntrinsicContentSize];
    
    if (formerIntrinsicContentSize.height != [self intrinsicContentSize].height) {
        [self animateTransition:^{} completion:^{}];
    }
}

- (void)animateTransition:(dispatch_block_t)transition completion:(dispatch_block_t)completion
{
    if (self.animateTransitions) {
        
        if ([self.delegate respondsToSelector:@selector(textViewWillChangeHeight:)]) {
            [self.delegate textViewWillChangeHeight:self];
        }
        
        [UIView animateWithDuration:self.animationDuration
                              delay:0
                            options:self.animationOptions | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             transition();
                             [self.viewToLayout setNeedsLayout];
                             [self.viewToLayout layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             completion();
                             if ([self.delegate respondsToSelector:@selector(textViewDidChangeHeight:)]) {
                                 [self.delegate textViewWillChangeHeight:self];
                             }
                         }];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(textViewWillChangeHeight:)]) {
            [self.delegate textViewWillChangeHeight:self];
        }
        transition();
        [self.viewToLayout layoutIfNeeded];
        completion();
        if ([self.delegate respondsToSelector:@selector(textViewDidChangeHeight:)]) {
            [self.delegate textViewWillChangeHeight:self];
        }
    }
}

#pragma mark - UIConstraintBasedCompatibility

- (CGSize)intrinsicContentSize
{
    CGSize s = [self sizeForContentSize:self.contentSize];
    return s;
}

#pragma mark - FMGrowingTextView

- (void)setMinimumHeight:(CGFloat)minimumHeight animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (animated) {
        [self animateTransition:^{
            self.minimumHeight = minimumHeight;
        } completion:completion];
    }
    else {
        self.minimumHeight = minimumHeight;
    }
}

- (void)setMaximumHeight:(CGFloat)maximumHeight animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (animated) {
        [self animateTransition:^{
            self.maximumHeight = maximumHeight;
        } completion:completion];
    }
    else {
        self.maximumHeight = maximumHeight;
    }
}

- (void)setMaximumHeight:(CGFloat)maximumHeight
{
    _maximumHeight = maximumHeight;
    [self invalidateIntrinsicContentSize];
}

- (void)setMinimumHeight:(CGFloat)minimumHeight
{
    _minimumHeight = minimumHeight;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)sizeForContentSize:(CGSize)contentSize
{
    return CGSizeMake(contentSize.width, [self heightForContentHeight:contentSize.height]);
}

- (void)setMinimumHeightWithNumberOfLines:(NSUInteger)numberOfLines animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    [self setMinimumHeight:[self heightForNumberOfLines:numberOfLines] animated:animated completion:completion];
}

- (void)setMaximumHeightWithNumberOfLines:(NSUInteger)numberOfLines animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    [self setMaximumHeight:[self heightForNumberOfLines:numberOfLines] animated:animated completion:completion];
}

- (CGFloat)heightForNumberOfLines:(NSUInteger)numberOfLines
{
    return self.font.lineHeight * numberOfLines + self.contentInset.top + self.contentInset.bottom;
}

- (CGFloat)heightForContentHeight:(CGFloat)contentHeight
{
    return MIN(MAX([self minimumHeight], contentHeight), [self maximumHeight]);
}

#pragma mark -

@end
