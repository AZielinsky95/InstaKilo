//
//  ViewController.m
//  InstaKilo
//
//  Created by Alejandro Zielinsky on 2018-04-25.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDragDelegate,UICollectionViewDropDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray<NSMutableArray<UIImage*>*>* subjectImages;
@property (nonatomic) NSMutableArray<UIImage*>* lowPolyImages;
@property (nonatomic) NSMutableArray<UIImage*>* otherImages;

@property (nonatomic) NSMutableArray<NSMutableArray<UIImage*>*>* favoriteImages;
@property (nonatomic) NSMutableArray<UIImage*>* favImages;
@property (nonatomic) NSMutableArray<UIImage*>* notFavImages;

@property (nonatomic) NSMutableArray<NSMutableArray<UIImage*>*>* currentSelection;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"pic1"],[UIImage imageNamed:@"pic2"],
                   [UIImage imageNamed:@"pic3"],[UIImage imageNamed:@"pic4"],[UIImage imageNamed:@"pic5"],[UIImage imageNamed:@"pic6"],[UIImage imageNamed:@"pic7"],[UIImage imageNamed:@"pic8"],[UIImage imageNamed:@"pic9"],[UIImage imageNamed:@"pic10"], nil];
    
    [self initializeSubjectImages];
    [self initializeFavoriteImages];
    
    
    self.currentSelection = self.subjectImages;
    
    self.collectionView.dragDelegate = self;
    self.collectionView.dropDelegate = self;
    //self.collectionView.dragDelegate = self;
    self.collectionView.dragInteractionEnabled = true;
}

-(void)initializeSubjectImages
{
    self.lowPolyImages = [[NSMutableArray alloc] initWithObjects:self.images[3],self.images[4],self.images[5],self.images[6],self.images[7],self.images[8],self.images[9], nil];
    
    self.otherImages = [[NSMutableArray alloc] initWithObjects:self.images[0],self.images[1],self.images[2], nil];
    
    self.subjectImages  = [[NSMutableArray alloc] initWithObjects:self.lowPolyImages,self.otherImages,nil];
}

-(void)initializeFavoriteImages
{
    self.favImages = [[NSMutableArray alloc] initWithObjects:self.images[0],self.images[1],self.images[2],self.images[3],self.images[4], nil];
    
 self.notFavImages = [[NSMutableArray alloc] initWithObjects:self.images[5],self.images[6],self.images[7],self.images[8],self.images[9], nil];
    
    self.favoriteImages  = [[NSMutableArray alloc] initWithObjects:self.favImages,self.notFavImages,nil];
}

- (IBAction)segmentedControlSwitched:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0)
    {
        self.currentSelection = self.subjectImages;
    }
    else
    {
        self.currentSelection = self.favoriteImages;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.currentSelection count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    PhotoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //if the cell doesnt have a tap gesture -> add one
    if(!cell.tap)
    {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [cell addGestureRecognizer:tapGesture];
    }
    cell.imageView.image = self.currentSelection[indexPath.section][indexPath.row];
    return cell;
}



- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        NSLog(@"DOUBLE TAP");
        PhotoCell *cell = (PhotoCell*)sender.view;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        NSMutableArray *section = self.currentSelection[path.section];
        
        NSInteger maxY = CGRectGetMaxY(self.view.frame);
        
        [UIView animateWithDuration:1
                         animations:^
         {
             cell.center = CGPointMake(cell.center.x,maxY);
         }
         completion:^(BOOL finished)
         {
             [section removeObjectAtIndex:path.row];
             [self.collectionView reloadData];
         }];
    }
    
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentSelection[section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader"                                                                                     forIndexPath:indexPath];
        UILabel *lbl = [header viewWithTag:1];
        
        if(self.currentSelection == self.subjectImages)
        {
            if(indexPath.section == 0)
            {
                lbl.text = @"Low Poly";
            }
            else if (indexPath.section == 1)
            {
                lbl.text = @"Other";
            }
        }
        else if(self.currentSelection == self.favoriteImages)
        {
            if(indexPath.section == 0)
            {
                lbl.text = @"Favorite";
            }
            else if (indexPath.section == 1)
            {
                lbl.text = @"Not Favorite";
            }
        }
        return header;
    }

    return nil;
}

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.currentSelection[indexPath.section][indexPath.row]];
    UIDragItem *itemToDrag = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    itemToDrag.localObject = indexPath;
    
    NSArray<UIDragItem*> *array = [[NSArray alloc] initWithObjects:itemToDrag, nil];
    
    return array;
}

-(UICollectionViewDropProposal*)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    UICollectionViewDropProposal *proposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove];
    return proposal;
}

- (void)collectionView:(nonnull UICollectionView *)collectionView performDropWithCoordinator:(nonnull id<UICollectionViewDropCoordinator>)coordinator
{
 
    for(id<UICollectionViewDropItem> item in coordinator.items)
    {
        id obj = self.currentSelection[item.sourceIndexPath.section][item.sourceIndexPath.item];
        [self.currentSelection[item.sourceIndexPath.section] removeObjectAtIndex:item.sourceIndexPath.item];
        [self.currentSelection[coordinator.destinationIndexPath.section] insertObject:obj atIndex:coordinator.destinationIndexPath.item];
        
        [collectionView performBatchUpdates:^{
            [collectionView deleteItemsAtIndexPaths:@[item.sourceIndexPath]];
            [collectionView insertItemsAtIndexPaths:@[coordinator.destinationIndexPath]];
        } completion:^(BOOL finished) {
            [coordinator dropItem:item.dragItem toItemAtIndexPath:coordinator.destinationIndexPath];
            
        }];
    }

}



@end
