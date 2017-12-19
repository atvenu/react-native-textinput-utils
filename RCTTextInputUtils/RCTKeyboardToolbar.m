//
//  RCTKeyboardToolbar.m
//  RCTKeyboardToolbar
//
//  Created by Kanzaki Mirai on 11/7/15.
//  Copyright © 2015 DickyT. All rights reserved.
//

#import "RCTKeyboardToolbar.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import "RCTTextField.h"
#import "RCTUITextField.h"
#import "RCTTextView.h"
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import "RCTKeyboardPicker.h"
#import "RCTTextViewExtension.h"
#import "RCTDatePicker.h"
#import "RCTDatePickerManager.h"
#import "RCTKeyboardDatePicker.h"

@implementation RCTKeyboardToolbar

#pragma mark -

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(configure:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        // The convert is little bit dangerous, change it if you are going to fock the project
        // Or do not assign any non-common property between UITextView and UITextView
        UIView<RCTBackedTextInputViewProtocol> *textView;
        if ([view class] == [RCTTextView class]) {
            RCTTextView *reactNativeTextView = ((RCTTextView *)view);
            textView = reactNativeTextView.backedTextInputView;
        }
        else {
            RCTTextField *reactNativeTextView = ((RCTTextField *)view);
            textView = reactNativeTextView.backedTextInputView;
        }
        
        if (options[@"tintColor"]) {
            NSLog(@"tintColor is %@", options[@"tintColor"]);
            textView.tintColor = [RCTConvert UIColor:options[@"tintColor"]];
        }

        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        NSInteger toolbarStyle = [RCTConvert NSInteger:options[@"barStyle"]];
        numberToolbar.barStyle = toolbarStyle;
        
        NSString *leftButtonText = [RCTConvert NSString:options[@"leftButton1Text"]];
        NSString *leftButton2Text = [RCTConvert NSString:options[@"leftButton2Text"]];
        NSString *rightButtonText = [RCTConvert NSString:options[@"rightButtonText"]];
        
        NSNumber *currentUid = [RCTConvert NSNumber:options[@"uid"]];
        
        NSMutableArray *toolbarItems = [NSMutableArray array];
        if (![leftButtonText isEqualToString:@""]) {
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:leftButtonText style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardLeftButton1:)];
            leftItem.tag = [currentUid intValue];
            [toolbarItems addObject:leftItem];
        }
        
        if (![leftButton2Text isEqualToString:@""]) {
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:leftButton2Text style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardLeftButton2:)];
            leftItem.tag = [currentUid intValue];
            [toolbarItems addObject:leftItem];
        }
        
        if (![leftButtonText isEqualToString:@""] && ![rightButtonText isEqualToString:@""]) {
            [toolbarItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        }
        if (![rightButtonText isEqualToString:@""]) {
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:rightButtonText style:UIBarButtonItemStyleDone target:self action:@selector(keyboardRightButton:)];
            //rightItem.tintColor = [UIColor colorWithRed:0x29/255.0 green:0x30/255.0 blue:0x33/255.0 alpha:1.0];

            rightItem.tag = [currentUid intValue];
            [toolbarItems addObject:rightItem];
        }
        numberToolbar.items = toolbarItems;
        
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
        
        callback(@[[NSNull null], [currentUid stringValue]]);
    }];
}

RCT_EXPORT_METHOD(dismissKeyboard:(nonnull NSNumber *)reactNode) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView resignFirstResponder];
        });
    }];
}

RCT_EXPORT_METHOD(moveCursorToLast:(nonnull NSNumber *)reactNode) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITextPosition *position = [textView.backedTextInputView endOfDocument];
            UITextRange *range = [textView.backedTextInputView textRangeFromPosition:position toPosition:position];
            [textView.backedTextInputView setSelectedTextRange:range notifyDelegate:YES];
        });
    }];
}

RCT_EXPORT_METHOD(setSelectedTextRange:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        RCTTextField *textView = ((RCTTextField *)view);
        
        NSNumber *startPosition = [RCTConvert NSNumber:options[@"start"]];
        NSNumber *endPosition = [RCTConvert NSNumber:options[@"length"]];
        
        NSRange range  = NSMakeRange([startPosition integerValue], [endPosition integerValue]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITextPosition *from = [textView.backedTextInputView positionFromPosition:[textView.backedTextInputView beginningOfDocument] offset:range.location];
            UITextPosition *to = [textView.backedTextInputView positionFromPosition:from offset:range.length];
            UITextRange *range = [textView.backedTextInputView textRangeFromPosition:from toPosition:to];
            [textView.backedTextInputView setSelectedTextRange:range notifyDelegate:YES];
        });
    }];
}

RCT_EXPORT_METHOD(setDate:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UIDatePicker *datePicker = ((UIDatePicker *)view.inputView);
        
        NSDate *date = [RCTConvert NSDate:options[@"date"]];
        
        [datePicker setDate: date];
    }];
}

RCT_EXPORT_METHOD(setPickerRowByIndex:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UIPickerView *pickerView = ((UIPickerView *)view.inputView);
        
        NSInteger *index = [RCTConvert NSInteger:options[@"index"]];
        
        [pickerView selectRow: index inComponent:0 animated:YES];
        
    }];
}

RCT_EXPORT_METHOD(reloadPickerData:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary *viewRegistry) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        RCTKeyboardPicker *pickerView = ((RCTKeyboardPicker *)view.inputView);
        
        NSArray *data = [RCTConvert NSArray:options[@"data"]];
        
        [pickerView setData: data];
        [pickerView reloadAllComponents];
        
    }];
}

-(void)dateSelected:(RCTKeyboardDatePicker*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardDatePickerViewDidSelected"
                                                    body:@{@"currentUid" : [currentUid stringValue], @"selectedDate": @(sender.date.timeIntervalSince1970 * 1000.0)}];
}

- (void)valueSelected:(RCTKeyboardPicker*)sender
{
    NSNumber *selectedIndex = [NSNumber numberWithLong:[sender selectedRowInComponent:0]];
    NSLog(@"Selected %d", [selectedIndex intValue]);
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardPickerViewDidSelected"
                                                    body:@{@"currentUid" : [currentUid stringValue], @"selectedIndex": [selectedIndex stringValue]}];
}

- (void)keyboardLeftButton1:(UIBarButtonItem*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardToolbarDidTouchLeftButton1"
                                                 body:@([currentUid intValue])];
}

- (void)keyboardLeftButton2:(UIBarButtonItem*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardToolbarDidTouchLeftButton2"
                                                 body:@([currentUid intValue])];
}

- (void)keyboardRightButton:(UIBarButtonItem*)sender
{
    NSNumber *currentUid = [NSNumber numberWithLong:sender.tag];
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardToolbarDidTouchRightButton"
                                                    body:@([currentUid intValue])];
}

@end
