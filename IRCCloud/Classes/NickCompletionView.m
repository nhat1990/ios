//
//  NickCompletionView.m
//  IRCCloud
//
//  Created by Sam Steele on 1/13/14.
//  Copyright (c) 2014 IRCCloud, Ltd. All rights reserved.
//

#import "NickCompletionView.h"
#import "UIColor+IRCCloud.h"
#import "ColorFormatter.h"

@implementation NickCompletionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor selectedBlueColor];
        _selection = -1;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor backgroundBlueColor];
        [self addSubview:_scrollView];
        [self setSuggestions:@[]];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _scrollView.frame = CGRectMake(1, 1, frame.size.width - 2, frame.size.height - 2);
#ifdef __IPHONE_7_0
    if([[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7)
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    else
#endif
        _font = [UIFont fontWithName:@"Helvetica" size:FONT_SIZE + 4];
}

-(void)setSuggestions:(NSArray *)suggestions {
    _suggestions = suggestions;
    
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int x = 0;
    for(NSString *label in _suggestions) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.titleLabel.font = _font;
        [b setTitle:label forState:UIControlStateNormal];
        [b setTitleColor:[UIColor selectedBlueColor] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(suggestionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [b sizeToFit];
        CGRect frame = b.frame;
        frame.origin.x = x;
        if(frame.size.width < 32)
            frame.size.width = 32;
        frame.size.height = _scrollView.frame.size.height;
        b.frame = frame;
        [_scrollView addSubview:b];
        x += frame.size.width + 12;
    }
    if(_scrollView.frame.size.width < x) {
        [_scrollView setContentInset:UIEdgeInsetsMake(0, 6, 0, 6)];
    } else {
        [_scrollView setContentInset:UIEdgeInsetsMake(0, (_scrollView.frame.size.width - x) / 2, 0, 0)];
    }
    [_scrollView setContentSize:CGSizeMake(x,_scrollView.frame.size.height)];
    _selection = -1;
}

-(NSString *)suggestion {
    if(_selection == -1 || _selection >= _suggestions.count)
        return nil;
    return [_suggestions objectAtIndex:_selection];
}


-(int)count {
    return _suggestions.count;
}

-(int)selection {
    return _selection;
}

-(void)setSelection:(int)selection {
    _selection = selection;
    
    if(_selection >= 0) {
        int i = 0;
        for(UIButton *b in [_scrollView subviews]) {
            if([b isKindOfClass:[UIButton class]]) {
                if(i == selection) {
                    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    b.titleLabel.backgroundColor = [UIColor selectedBlueColor];
                    [_scrollView scrollRectToVisible:b.frame animated:YES];
                } else {
                    [b setTitleColor:[UIColor selectedBlueColor] forState:UIControlStateNormal];
                    b.titleLabel.backgroundColor = [UIColor clearColor];
                }
                i++;
            }
        }
    }
}

-(void)suggestionTapped:(UIButton *)sender {
    [[UIDevice currentDevice] playInputClick];
    [_completionDelegate nickSelected:sender.titleLabel.text];
}

- (BOOL) enableInputClicksWhenVisible {
    return YES;
}
@end
