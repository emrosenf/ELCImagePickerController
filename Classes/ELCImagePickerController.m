//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

@implementation ELCImagePickerController

@synthesize delegate, assets=assets;

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)selectedAssets:(NSArray*)_assets {
    assets = _assets;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([delegate respondsToSelector:@selector(elcImagePickerController:willFinishPickingThisManyMediaItems:)]){
            [self.delegate elcImagePickerController:self 
                willFinishPickingThisManyMediaItems:[NSNumber numberWithInt:_assets.count]];
        }    

        NSMutableArray *retVal = [[[NSMutableArray alloc] init] autorelease];
        for(ALAsset *asset in _assets) {
            @autoreleasepool {
                

            NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
            [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
            [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
                        
            if([delegate respondsToSelector:@selector(elcImagePickerController:hasMediaWithInfo:)]){
                    [delegate elcImagePickerController:self hasMediaWithInfo:workingDictionary];
            }

            
                [retVal addObject:workingDictionary];

            [workingDictionary release];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
                [delegate elcImagePickerController:self didFinishPickingMediaWithInfo:retVal];
            }
            
        });

    });
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}

@end
