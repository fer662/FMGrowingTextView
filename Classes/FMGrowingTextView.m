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
    [self setMaximumHeightWithNumberOfLines:1];
    [self setMaximumHeightWithNumberOfLines:4];
    
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
    CGSize formerIntrinsicContentSize = [self intrinsicContentSize];
    [super setContentSize:contentSize];
    [self invalidateIntrinsicContentSize];
    
    if (formerIntrinsicContentSize.height != [self intrinsicContentSize].height) {
        if (self.animateTransitions) {
            
            if ([self.delegate respondsToSelector:@selector(textViewWillChangeHeight:)]) {
                [self.delegate textViewWillChangeHeight:self];
            }
            
            [UIView animateWithDuration:self.animationDuration
                                  delay:0
                                options:self.animationOptions | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self.viewToLayout setNeedsLayout];
                                 [self.viewToLayout layoutIfNeeded];
                             } completion:^(BOOL finished) {
                                 if ([self.delegate respondsToSelector:@selector(textViewDidChangeHeight:)]) {
                                     [self.delegate textViewWillChangeHeight:self];
                                 }
                             }];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(textViewWillChangeHeight:)]) {
                [self.delegate textViewWillChangeHeight:self];
            }
            [self.viewToLayout layoutIfNeeded];
            if ([self.delegate respondsToSelector:@selector(textViewDidChangeHeight:)]) {
                [self.delegate textViewWillChangeHeight:self];
            }
        }
    }
}

#pragma mark - UIConstraintBasedCompatibility

- (CGSize)intrinsicContentSize
{
    return [self sizeForContentSize:self.contentSize];
}

#pragma mark - FMGrowingTextView

- (CGSize)sizeForContentSize:(CGSize)contentSize
{
    return CGSizeMake(contentSize.width, [self heightForContentHeight:contentSize.height]);
}

- (void)setMinimumHeightWithNumberOfLines:(NSUInteger)numberOfLines
{
    self.minimumHeight = [self heightForNumberOfLines:numberOfLines];
}

- (void)setMaximumHeightWithNumberOfLines:(NSUInteger)numberOfLines
{
    self.maximumHeight = [self heightForNumberOfLines:numberOfLines];
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
