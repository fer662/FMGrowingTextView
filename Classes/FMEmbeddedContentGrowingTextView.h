//
//  FMEmbeddedContentGrowingTextView.h
//  Pods
//
//  Created by Fernando Mazzon on 9/2/14.
//
//

#import "FMGrowingTextView.h"

@class FMEmbeddedContentGrowingTextView;
@protocol FMEmbeddedContentGrowingTextViewDelegate <FMGrowingTextViewDelegate>

- (void)growingTextViewDidDeleteContent:(FMEmbeddedContentGrowingTextView *)growingTextView;

@end

@interface FMEmbeddedContentGrowingTextView : FMGrowingTextView

@property (nonatomic, weak) id<FMEmbeddedContentGrowingTextViewDelegate> delegate;
@property (nonatomic, assign) BOOL hasInsertedContent;

@property (nonatomic, strong) UIView *embeddedContentView;

- (NSString *)sanitizedText;

@property (nonatomic, strong) UIResponder *overrideNextResponder;

@end
