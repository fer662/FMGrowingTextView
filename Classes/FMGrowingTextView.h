//
//  FMGrowingTextView.h
//  FMGrowingTextView
//
//  Created by Fernando Mazzon on 2/21/14.
//  Copyright (c) 2014 Fernando Mazzon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMGrowingTextView;
@protocol FMGrowingTextViewDelegate <UITextViewDelegate>

@optional

- (void)textViewWillChangeHeight:(FMGrowingTextView *)textView;
- (void)textViewDidChangeHeight:(FMGrowingTextView *)textView;

@end

@interface FMGrowingTextView : UITextView

/**
 defines the minimum possible height this textView can have, even if it's content could fit in a smaller height.
 */
@property (nonatomic, assign) CGFloat minimumHeight;

/**
 defines the maximum possible height this textView can have, even if it's content wouldn't fit.
 */
@property (nonatomic, assign) CGFloat maximumHeight;

/**
 defines whether height changes should be animated or not. Default is YES.
 */
@property (nonatomic, assign) BOOL animateTransitions;

/**
 if height changes are animated, defines how much time they should take to complete. Default is 0.1 seconds.
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 if height changes are animated, defines further parameters for the transition, such as the curve type. Default is
 UIViewAnimationOptionCurveLinear.
 */
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;

@property (nonatomic, weak) IBOutlet UIView *viewToLayout;
@property (nonatomic, weak) IBOutlet id<FMGrowingTextViewDelegate> delegate;

/**
 convenience method to set maximumHeight the the correct value to completely display the passed amount of lines
 */
- (void)setMinimumHeightWithNumberOfLines:(NSUInteger)numberOfLines;

/**
 convenience method to set maximumHeight the the correct value to completely display the passed amount of lines
 */
- (void)setMaximumHeightWithNumberOfLines:(NSUInteger)numberOfLines;

/**
 returns actual the height for the textView depending on it's contentHeight. Default implementation only ensures
 contentHeight is between minimumHeight and maximumHeight by limiting it. Could be overriden to take additional
 considerations such as content besides text.
 */
- (CGFloat)heightForContentHeight:(CGFloat)contentHeight;

/**
 returns the height the textView should have when it has the passed amount of lines. Default implementations relies on
 the UIFont's lineHeight, and adds the top and bottom content insets. Used by setMinimumHeightWithNumberOfLines: and
 setMaximumHeightWithNumberOfLines:
 */
- (CGFloat)heightForNumberOfLines:(NSUInteger)numberOfLines;

@end
