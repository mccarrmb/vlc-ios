//
//  VLCMultiSelectionMenuView.m
//  VLC for iOS
//
//  Created by Felix Paul Kühne on 09/03/15.
//  Copyright (c) 2015 VideoLAN. All rights reserved.
//

#import "VLCMultiSelectionMenuView.h"

#define buttonWidth 32.
#define buttonHeight 35.
#define spacer 8.

@interface VLCMultiSelectionMenuView ()
{
    UIButton *_equalizerButton;
    UIButton *_chapterSelectorButton;
    UIButton *_repeatButton;
    UIButton *_lockButton;

    BOOL _showsEQ;
}

@end

@implementation VLCMultiSelectionMenuView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0., 0., buttonWidth, buttonHeight)];

    if (self) {
        _equalizerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_equalizerButton setImage:[UIImage imageNamed:@"equalizerIcon"] forState:UIControlStateNormal];
        _equalizerButton.titleLabel.textColor = [UIColor whiteColor];
        _equalizerButton.frame = CGRectMake(spacer, spacer, buttonWidth, buttonHeight);
        [_equalizerButton addTarget:self action:@selector(equalizerAction:) forControlEvents:UIControlEventTouchUpInside];
        _equalizerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_equalizerButton];

        _chapterSelectorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chapterSelectorButton setImage:[UIImage imageNamed:@"chaptersIcon"] forState:UIControlStateNormal];
        _chapterSelectorButton.titleLabel.textColor = [UIColor whiteColor];
        _chapterSelectorButton.frame = CGRectMake(spacer, spacer + buttonHeight + spacer, buttonWidth, buttonHeight);
        [_chapterSelectorButton addTarget:self action:@selector(chapterSelectorAction:) forControlEvents:UIControlEventTouchUpInside];
        _chapterSelectorButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_chapterSelectorButton];

        _repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatButton setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
        _repeatButton.frame = CGRectMake(spacer, spacer + buttonHeight + spacer + buttonHeight + spacer, buttonWidth, buttonHeight);
        [_repeatButton addTarget:self action:@selector(repeatAction:) forControlEvents:UIControlEventTouchUpInside];
        _repeatButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_repeatButton];

        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockButton setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        _lockButton.frame = CGRectMake(spacer, spacer + buttonHeight + spacer + buttonHeight + spacer + buttonHeight + spacer, buttonWidth, buttonHeight);
        [_lockButton addTarget:self action:@selector(lockAction:) forControlEvents:UIControlEventTouchUpInside];
        _lockButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_lockButton];
    }
    return self;
}

- (CGSize)proposedDisplaySize
{
    _equalizerButton.hidden = !_showsEqualizer;
    _chapterSelectorButton.hidden = !_mediaHasChapters;

    CGFloat height;
    CGRect workFrame;

    if (_showsEqualizer) {
        if (_mediaHasChapters) {
            height = 5. * spacer + 4. * buttonHeight;
            workFrame = _equalizerButton.frame;
            workFrame.origin.y = spacer;
            _equalizerButton.frame = workFrame;
            _equalizerButton.hidden = NO;
            workFrame = _chapterSelectorButton.frame;
            workFrame.origin.y = spacer * 2. + buttonHeight;
            _chapterSelectorButton.frame = workFrame;
            _chapterSelectorButton.hidden = NO;
            workFrame = _repeatButton.frame;
            workFrame.origin.y = spacer * 3. + buttonHeight * 2.;
            _repeatButton.frame = workFrame;
            workFrame = _lockButton.frame;
            workFrame.origin.y = spacer * 4. + buttonHeight * 3.;
            _lockButton.frame = workFrame;
        } else {
            height = 4. * spacer + 3. * buttonHeight;
            workFrame = _equalizerButton.frame;
            workFrame.origin.y = spacer;
            _equalizerButton.frame = workFrame;
            _equalizerButton.hidden = NO;
            _chapterSelectorButton.hidden = YES;
            workFrame = _repeatButton.frame;
            workFrame.origin.y = spacer * 2. + buttonHeight;
            _repeatButton.frame = workFrame;
            workFrame = _lockButton.frame;
            workFrame.origin.y = spacer * 3. + buttonHeight * 2.;
            _lockButton.frame = workFrame;
        }
    } else {
        if (_mediaHasChapters) {
            height = 4. * spacer + 3. * buttonHeight;
            _equalizerButton.hidden = YES;
            workFrame = _chapterSelectorButton.frame;
            workFrame.origin.y = spacer;
            _chapterSelectorButton.frame = workFrame;
            _chapterSelectorButton.hidden = NO;
            workFrame = _repeatButton.frame;
            workFrame.origin.y = spacer * 2. + buttonHeight;
            _repeatButton.frame = workFrame;
            workFrame = _lockButton.frame;
            workFrame.origin.y = spacer * 3. + buttonHeight * 2;
            _lockButton.frame = workFrame;
        } else {
            height = 3. * spacer + 2. * buttonHeight;
            _equalizerButton.hidden = YES;
            _chapterSelectorButton.hidden = YES;
            workFrame = _repeatButton.frame;
            workFrame.origin.y = spacer;
            _repeatButton.frame = workFrame;
            workFrame = _lockButton.frame;
            workFrame.origin.y = spacer * 2. + buttonHeight;
            _lockButton.frame = workFrame;
        }
    }

    return CGSizeMake(spacer + buttonWidth + spacer, height);
}

- (void)setDisplayRepeatOne:(BOOL)displayRepeatOne
{
    if (displayRepeatOne)
        [_repeatButton setImage:[UIImage imageNamed:@"repeatOne"] forState:UIControlStateNormal];
    else
        [_repeatButton setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
}

- (void)setDisplayLock:(BOOL)displayLock
{
    if (displayLock)
        [_lockButton setBackgroundColor:[UIColor VLCOrangeTintColor]];
    else
        [_lockButton setBackgroundColor:[UIColor clearColor]];
}

- (void)equalizerAction:(id)sender
{
    [self.delegate toggleEqualizer];
    [self.delegate hideMenu];
}

- (void)chapterSelectorAction:(id)sender
{
    [self.delegate toggleChapterAndTitleSelector];
    [self.delegate hideMenu];
}

- (void)repeatAction:(id)sender
{
    [self.delegate toggleRepeatMode];
}

- (void)lockAction:(id)sender
{
    [self.delegate toggleUILock];
}

@end
