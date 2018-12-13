//
//  DrawPDFView.h
//  Test
//
//  Created by Yomob on 2018/12/13.
//  Copyright © 2018年 Yomob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawPDFView : UIView
{
    CGPDFDocumentRef pdfDocument;
    NSInteger        page;
}

- (instancetype)initWithFrame:(CGRect)frame atPage:(NSInteger)page withPDFDoc:(CGPDFDocumentRef)pdfDoc;

@end

NS_ASSUME_NONNULL_END
