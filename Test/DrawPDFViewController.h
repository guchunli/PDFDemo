//
//  DrawPDFViewController.h
//  Test
//
//  Created by Yomob on 2018/12/13.
//  Copyright © 2018年 Yomob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawPDFViewController : UIViewController

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) CGPDFDocumentRef pdfDocument;

- (instancetype)initWithPage:(NSInteger)pageNumber withPDFDoc:(CGPDFDocumentRef)pdfDoc;

@end

NS_ASSUME_NONNULL_END
