//
//  FMEmbeddedContentGrowingTextView.m
//  Pods
//
//  Created by Fernando Mazzon on 9/2/14.
//
//

#import "FMEmbeddedContentGrowingTextView.h"

@interface FMEmbeddedContentGrowingTextView () <FMGrowingTextViewDelegate>

@property (nonatomic, assign) NSObject<FMEmbeddedContentGrowingTextViewDelegate>* realDelegate;

@property (nonatomic, strong) NSLayoutConstraint *contentLeftLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentTopLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentWidthLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentHeightLayoutConstraint;

@end

@implementation FMEmbeddedContentGrowingTextView

@synthesize hasInsertedContent = _hasInsertedContent;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self embeddedContentGrowingTextView_initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self embeddedContentGrowingTextView_initialize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hasInsertedContent = YES;
    });
}

- (void)embeddedContentGrowingTextView_initialize
{
    super.delegate = self;
    
    self.embeddedContentView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 64, 64)];
    self.embeddedContentView.backgroundColor = [UIColor blackColor];
    self.embeddedContentView.layer.cornerRadius = 5;
    self.embeddedContentView.layer.masksToBounds = YES;
    self.embeddedContentView.hidden = YES;
    
    [self addSubview:self.embeddedContentView];
    [self setNeedsUpdateConstraints];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        return [self.realDelegate textViewShouldBeginEditing:textView];
    }
    else {
        return YES;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        return [self.realDelegate textViewShouldEndEditing:textView];
    }
    else {
        return YES;
    }
    return [self.realDelegate textViewShouldEndEditing:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate textViewDidEndEditing:textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.hasInsertedContent && (([[self.text substringWithRange:range] rangeOfString:[self fakeText]].length > 0 &&
                                     [text rangeOfString:[self fakeText]].length == 0) || (range.location == 0 && range.length == 0 && text.length == 0))) {
        [self contentDeleted];
        return NO;
    }
    
    if ([self.realDelegate respondsToSelector:_cmd]) {
        return [self.realDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    else {
        return YES;
    }
}

- (void)setDelegate:(NSObject<FMEmbeddedContentGrowingTextViewDelegate> *)aDelegate
{
    self.realDelegate = aDelegate;
}

- (void)contentDeleted
{
    self.hasInsertedContent = NO;
    [self.realDelegate growingTextViewDidDeleteContent:self];
}

- (void)setHasInsertedContent:(BOOL)hasInsertedContent
{
    if (hasInsertedContent != _hasInsertedContent) {
        _hasInsertedContent = hasInsertedContent;
        self.embeddedContentView.hidden = !hasInsertedContent;
        
        if (!hasInsertedContent) {
            self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
            [self setMinimumHeightWithNumberOfLines:1 animated:NO completion:^{}];
        }
        else {
            self.textContainerInset = UIEdgeInsetsMake(64 + 12, 0, 0, 0);
            [self setMinimumHeight:64 + 12 animated:YES completion:^{}];
        }

        self.text = [self.text stringByAppendingString:@" "];
        self.text = [self.text substringToIndex:self.text.length - 1];
        [self setNeedsDisplay];
    }
}

- (BOOL)hasInsertedContent
{
    return _hasInsertedContent;
}

- (NSString *)sanitizedText
{
    return [self sanitizedText:super.text];
}

- (NSString *)sanitizedText:(NSString *)text
{
    return [text stringByReplacingOccurrencesOfString:[self fakeText] withString:@""]?:@"";
}

- (NSString *)text
{
    return [[self fakeText] stringByAppendingString:[self sanitizedText:super.text]];
}

- (void)setText:(NSString *)text
{
    super.text = [[self fakeText] stringByAppendingString:[self sanitizedText:text]];
    if ([[self realDelegate] respondsToSelector:@selector(textViewDidChange:)]) {
        [self.realDelegate textViewDidChange:self];
    }
}

- (NSString *)fakeText
{
    return @"\u200B";;
}

#pragma mark -

- (UIResponder *)nextResponder
{
    if (self.overrideNextResponder != nil)
        return self.overrideNextResponder;
    else
        return [super nextResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.overrideNextResponder != nil) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
