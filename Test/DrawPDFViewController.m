//
//  DrawPDFViewController.m
//  Test
//
//  Created by Yomob on 2018/12/13.
//  Copyright © 2018年 Yomob. All rights reserved.
//

#import "DrawPDFViewController.h"
#import "DrawPDFView.h"

@interface DrawPDFViewController () <UIScrollViewDelegate>
{
    DrawPDFView *drawPDFView;
}

@end

@implementation DrawPDFViewController
@synthesize page, pdfDocument;

- (instancetype)initWithPage:(NSInteger)pageNumber withPDFDoc:(CGPDFDocumentRef)pdfDoc
{
    self = [super init];
    
    if (self)
    {
        self.page = pageNumber;
        self.pdfDocument = pdfDoc;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 2.0;
    scrollView.minimumZoomScale = 1.0;
    [self.view addSubview:scrollView];
    
    drawPDFView = [[DrawPDFView alloc] initWithFrame:self.view.bounds atPage:self.page withPDFDoc:self.pdfDocument];
    [scrollView addSubview:drawPDFView];
    
    UILabel *pageLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-30, self.view.bounds.size.width, 30)];
    pageLab.text = [NSString stringWithFormat:@"%ld/%ld",self.page, CGPDFDocumentGetNumberOfPages(self.pdfDocument)];
    pageLab.textColor = [UIColor lightGrayColor];
    pageLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:pageLab];
    
}

#pragma - mark UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return drawPDFView;
}

@end
