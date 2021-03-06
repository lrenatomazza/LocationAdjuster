//
//  TWSecondViewController.m
//  TWLocationAdjuster
//
//  Created by Andrey Tabachnik on 7/21/12.
//  Copyright (c) 2012 Truckwiser. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "TWGeocodeHelper.h"

#import "TWSecondViewController.h"
#import "TWMapPin.h"

@interface TWSecondViewController ()
{
    TWMapPin *_pin;
}

@end

@implementation TWSecondViewController

@synthesize textView = _textView;
@synthesize locationManager = _locationManager;
@synthesize address         = _address;
@synthesize mapView         = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        [self clear];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapView setShowsUserLocation:NO];
    
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setAddress:nil];
    [self setMapView:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

# pragma mark - protocol MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D coords = [_mapView centerCoordinate];
    
    if (_pin) {
        [_mapView removeAnnotation:_pin];
    }
    _pin = [[TWMapPin alloc] initWithCoordinates:coords placeName:@"your location" description:@"i am glad you came"];
    [_mapView addAnnotation:_pin];
    
    self.textView.text = [NSString stringWithFormat:@"your pin is located at: %f %f", coords.latitude, coords.longitude]; 
}

# pragma mark - location
- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    NSDate* time = newLocation.timestamp;
    NSTimeInterval timePeriod = [time timeIntervalSinceNow];
    if(timePeriod < 2.0 ) {
        [manager stopUpdatingLocation];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 250, 250);
        [self.mapView setRegion:region animated:YES];
        
        if (_pin) {
            [_mapView removeAnnotation:_pin];
        }
        
        CLLocationCoordinate2D coords = newLocation.coordinate;
        _pin = [[TWMapPin alloc] initWithCoordinates:coords placeName:@"your location" description:@"i am glad you came"];
        [_mapView addAnnotation:_pin];
    }
}

- (void)centerMapViewForAddress:(NSString *)address
{
    [TWGeocodeHelper geocodeAddress:address withCompletionHanlder:^(CLLocationCoordinate2D coords) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coords, 250, 250);        
        [self.mapView setRegion:region animated:YES];
        
        if (_pin) {
            [_mapView removeAnnotation:_pin];
        }
        
        _pin = [[TWMapPin alloc] initWithCoordinates:coords placeName:@"your location" description:@"i am glad you came"];
        [_mapView addAnnotation:_pin];
    }];
}

# pragma mark - UITextFieldDelegate protocol
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (textField.tag == 2) {
        [textField resignFirstResponder];
        if ([self.address.text length] > 4) {
            [self centerMapViewForAddress:self.address.text];
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

# pragma mark - helpers

- (void) clear
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
}

@end
