//
//  JDRDMShowImagesFullScreen.h
//  RDM
//
//  Created by phh on 15/11/28.
//  Copyright © 2015年 phh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDRDMShowImagesFullScreen : NSObject

+ (JDRDMShowImagesFullScreen*)shareJDRDMShowImagesFullScreenManager;
- (void)showImages:(NSArray<UIImageView*>*)imageArray currentShowImageIndex:(NSUInteger)index;
@end
