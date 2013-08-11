//
//  VLCLocalServerListViewController.m
//  VLC for iOS
//
//  Created by Felix Paul Kühne on 10.08.13.
//  Copyright (c) 2013 VideoLAN. All rights reserved.
//
//  Refer to the COPYING file of the official project for license.
//

#import "VLCLocalServerListViewController.h"
#import "UIBarButtonItem+Theme.h"
#import "VLCAppDelegate.h"
#import "UPnPManager.h"
#import "VLCLocalNetworkListCell.h"
#import "VLCLocalServerFolderListViewController.h"

@interface VLCLocalServerListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIBarButtonItem *_backToMenuButton;
    NSArray *_filteredDevices;
    NSArray *_devices;
}

@end

@implementation VLCLocalServerListViewController

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.view = _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UPnPDB* db = [[UPnPManager GetInstance] DB];

    _devices = [db rootDevices]; //BasicUPnPDevice

    [db addObserver:(UPnPDBObserver*)self];

    //Optional; set User Agent
    [[[UPnPManager GetInstance] SSDP] setUserAgentProduct:[NSString stringWithFormat:@"VLC for iOS/%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] andOS:@"iOS"];

    //Search for UPnP Devices
    [[[UPnPManager GetInstance] SSDP] searchSSDP];

    _backToMenuButton = [UIBarButtonItem themedRevealMenuButtonWithTarget:self andSelector:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = _backToMenuButton;

    self.tableView.separatorColor = [UIColor colorWithWhite:.122 alpha:1.];
    self.view.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];

    self.title = NSLocalizedString(@"LOCAL_NETWORK", @"");
}

- (IBAction)goBack:(id)sender
{
    [[(VLCAppDelegate*)[UIApplication sharedApplication].delegate revealController] toggleSidebar:![(VLCAppDelegate*)[UIApplication sharedApplication].delegate revealController].sidebarShowing duration:kGHRevealSidebarDefaultAnimationDuration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return NO;
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredDevices.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2 == 0)? [UIColor blackColor]: [UIColor colorWithWhite:.122 alpha:1.];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalNetworkCell";

    VLCLocalNetworkListCell *cell = (VLCLocalNetworkListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [VLCLocalNetworkListCell cellWithReuseIdentifier:CellIdentifier];

    BasicUPnPDevice *device = _filteredDevices[indexPath.row];
    [cell setTitle:[device friendlyName]];
    UIImage *icon = [device smallIcon];
    [cell setIcon:icon];
    [cell setIsDirectory:YES];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BasicUPnPDevice *device = _filteredDevices[indexPath.row];
    if ([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"]) {
        MediaServer1Device *server = (MediaServer1Device*)device;
        VLCLocalServerFolderListViewController *targetViewController = [[VLCLocalServerFolderListViewController alloc] initWithDevice:server header:[device friendlyName] andRootID:@"0"];
        [[self navigationController] pushViewController:targetViewController animated:YES];
    } else if ([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaRenderer:1"]) {
        //FIXME: euh, we don't do rendering atm, at least not here.
    }
}

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    APLog(@"UPnPDBWillUpdate %d", _devices.count);
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    APLog(@"UPnPDBUpdated %d", _devices.count);

    NSUInteger count = _devices.count;
    BasicUPnPDevice *device;
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    for (NSUInteger x = 0; x < count; x++) {
        device = _devices[x];
        if ([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"])
            [mutArray addObject:device];
    }
    _filteredDevices = nil;
    _filteredDevices = [NSArray arrayWithArray:mutArray];

    [self.tableView performSelectorOnMainThread : @ selector(reloadData) withObject:nil waitUntilDone:YES];
}

@end
