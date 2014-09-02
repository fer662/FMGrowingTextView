//
//  FMEmbeddedContentGrowingTextView.m
//  Pods
//
//  Created by Fernando Mazzon on 9/2/14.
//
//

#import "FMEmbeddedContentGrowingTextView.h"

@interface FMEmbeddedContentGrowingTextView () <FMGrowingTextViewDelegate>

@property (nonatomic, weak) NSObject<FMEmbeddedContentGrowingTextViewDelegate>* realDelegate;
@property (nonatomic, assign) UIEdgeInsets realTextContainerInsets;

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
}

- (void)embeddedContentGrowingTextView_initialize
{
    super.delegate = self;
    
    self.realTextContainerInsets = UIEdgeInsetsMake(8, 0, 8, 0);
    self.embeddedContentInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    self.embeddedContentSize = CGSizeMake(64, 64);
    
    self.embeddedContentView = [[UIView alloc] initWithFrame:CGRectMake(self.embeddedContentInsets.left,
                                                                        self.embeddedContentInsets.top,
                                                                        self.embeddedContentSize.width,
                                                                        self.embeddedContentSize.height)];
    self.embeddedContentView.backgroundColor = [UIColor grayColor];
    self.embeddedContentView.layer.cornerRadius = 5;
    self.embeddedContentView.layer.masksToBounds = YES;
    self.embeddedContentView.hidden = YES;
    
    [self addSubview:self.embeddedContentView];
    [self setNeedsUpdateConstraints];
}

- (void)setEmbeddedContentInsets:(UIEdgeInsets)embeddedContentInsets
{
    _embeddedContentInsets = embeddedContentInsets;
    [self setHasInsertedContent:_hasInsertedContent forceUpdate:YES];
}

- (void)setEmbeddedContentSize:(CGSize)embeddedContentSize
{
    _embeddedContentSize = embeddedContentSize;
    [self setHasInsertedContent:_hasInsertedContent forceUpdate:YES];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    _realTextContainerInsets = textContainerInset;
    [self setHasInsertedContent:_hasInsertedContent forceUpdate:YES];
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
    [self setHasInsertedContent:hasInsertedContent forceUpdate:NO];
}

- (void)setHasInsertedContent:(BOOL)hasInsertedContent forceUpdate:(BOOL)forceUpdate
{
    if (hasInsertedContent != _hasInsertedContent || forceUpdate) {
        _hasInsertedContent = hasInsertedContent;
        self.embeddedContentView.hidden = !hasInsertedContent;
        
        if (!hasInsertedContent) {
            super.textContainerInset = self.realTextContainerInsets;
            [self setMinimumHeightWithNumberOfLines:1 animated:NO completion:^{}];
        }
        else {
            super.textContainerInset = UIEdgeInsetsMake(self.embeddedContentSize.height + self.embeddedContentInsets.top + self.embeddedContentInsets.bottom,
                                                       self.realTextContainerInsets.left,
                                                       self.realTextContainerInsets.bottom,
                                                       self.realTextContainerInsets.right);
            [self setMinimumHeight:self.embeddedContentSize.height + self.embeddedContentInsets.top + self.embeddedContentInsets.bottom animated:YES completion:^{}];
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
