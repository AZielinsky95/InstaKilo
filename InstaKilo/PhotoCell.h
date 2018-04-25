//
//  photoCell.h
//  InstaKilo
//
//  Created by Alejandro Zielinsky on 2018-04-25.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

typedef enum
{
    kLowPoly,
    kOther
}Subject;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) Subject *subject;
@property (nonatomic) UITapGestureRecognizer *tap;
@end
