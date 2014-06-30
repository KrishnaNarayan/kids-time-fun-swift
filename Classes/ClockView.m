//
//  ClockView.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/12/09.
//  Revised by Krishna Narayan on 9/17/09
//		--Updated graphics
//		--Added tell a friend
//		--Changed app name to Kids Learn To Tell Time
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

#import "ClockView.h"
#import "KidsTimeFunAppState.h"

@implementation ClockView

@synthesize hours;
@synthesize minutes;
@synthesize seconds;
@synthesize PM;
@synthesize showSeconds;
@synthesize showClockAsAnalog;
@synthesize showMinutesOffsetInHoursHand;
@synthesize showAMPM;
@synthesize showDayNight;

//Macros to convert hours, minutes and seconds to angles in radians
#define hoursToRadiansHM(h, m) ((M_PI/2)-(((h*2*M_PI)/12)+((m/60)*(0.75*2*M_PI/12))))
#define hoursToRadiansH(h) ((M_PI/2)-((h*2*M_PI)/12))
#define minutesToRadians(m) ((M_PI/2)-((m*2*M_PI)/60))
#define secondsToRadians(s) ((M_PI/2)-((s*2*M_PI)/60))

//Some convenience macros
#define smallerOf(a, b) a<b?a:b
#define greaterOf(a, b) a>b?a:b

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Clock Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext ();	// Get current graphics context
	//initialize radial coordinates
	float r = 0.0f, theta = 0.0f;
	//initialize cartesian coordinates
	float x_0 = 0.0f, y_0 = 0.0f;	//Origin
	float x = 0.0f, y = 0.0f;		//coordinates
	float x_c = 0.0f, y_c = 0.0f;	//center
	float x_l = 0.0f, y_w = 0.0f;	//bounds
	//Load Origin points
	x_0 = 0.0f;
	y_0 = 0.0f;
	//Load bounds - both length and width
	x_l = self.bounds.size.width;
	y_w = self.bounds.size.height;
	//diameter for the clock should be smaller of the two dimensions
	int d = 0.0f;	//initialize diameter
	d = smallerOf(x_l-x_0, y_w-y_0);	//load diameter
	r = d/2;	//radius = diameter/2
	//So the center for this circle (clock) should be
	x_c = (x_0+x_l)/2;
	y_c = (y_0+y_w)/2;
	//and clock face image start points will be
	x = x_c-r;
	y = y_c-r;
	//Load Clock Face with the start points and diameter above (circle in a square)
	UIImage *img = [UIImage imageNamed:@"Clock Face"]; //Load clock face image
	//Draw clock face - with diameter
	[img drawInRect:CGRectMake(x, y, d, d)];
	
	//Now draw hours hand
	//Get radial coordinates
	float r_h = 0.0f;	//initialize radius for the hand
	r_h = r*0.40;	//40% of the clock face radius - it is smallest hand
	//Now load angle based on the hours
	if (showMinutesOffsetInHoursHand)
		theta = hoursToRadiansHM(self.hours, self.minutes);
	else
		theta = hoursToRadiansH(self.hours);
	//Convert to cartesian - remember in CorGraphics y coordinate is reversed (-y)
	//And also it's origin will be the center of clock i.e. x_c, y_c
	x = r_h * cos(theta);
	y = -1 * r_h * sin(theta);
	//now convert these to coordinates from origin x_0, y_0
	x = x+x_c;
	y = y+y_c;
	//Now draw a line 3 pixels wide from center (x_c, y_c) to the above point (x, y)
	CGContextSetLineWidth (context, 3.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.75f);
	CGContextSetStrokeColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	CGContextMoveToPoint (context, x_c, y_c);
	CGContextAddLineToPoint (context, x, y);
	//Stroke Path Now
	CGContextStrokePath (context);
	//Now minutes hand
	//Get radial coordinates
	float r_m = 0.0f;
	r_m = r*0.60;
	theta = minutesToRadians(self.minutes);
	//Convert to cartesian - remember in CorGraphics y coordinate is reversed (-y)
	//And also it's origin will be the center of clock i.e. x_c, y_c
	x = r_m * cos(theta);
	y = -1 * r_m * sin(theta);
	//now convert these to coordinates from origin x_0, y_0
	x = x+x_c;
	y = y+y_c;
	//Now draw a line 3 pixels wide from center (x_c, y_c) to the above point (x, y)
	CGContextSetLineWidth (context, 3.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.75f);
	CGContextSetStrokeColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	CGContextMoveToPoint (context, x_c, y_c);
	CGContextAddLineToPoint (context, x, y);
	//Stroke Path Now
	CGContextStrokePath (context);
	//And optionally seconds hand
	if (showSeconds) {
		//Get radial coordinates
		float r_s = 0.0f;
		r_s = r*0.64;
		theta = secondsToRadians(self.seconds);
		//Convert to cartesian - remember in CorGraphics y coordinate is reversed (-y)
		//And also it's origin will be the center of clock i.e. x_c, y_c
		x = r_s * cos(theta);
		y = -1 * r_s * sin(theta);
		//now convert these to coordinates from origin x_0, y_0
		x = x+x_c;
		y = y+y_c;
		//Now draw a line 1 pixels wide from center (x_c, y_c) to the above point (x, y)
		CGContextSetLineWidth (context, 1.0f);
		CGContextSetLineCap(context, kCGLineCapRound);
		CGContextSetAlpha(context, 0.50f);
		CGContextSetStrokeColorWithColor (context, [UIColor purpleColor].CGColor);
		CGContextSetFillColorWithColor (context, [UIColor purpleColor].CGColor);
		CGContextMoveToPoint (context, x_c, y_c);
		CGContextAddLineToPoint (context, x, y);
		//Stroke Path Now
		CGContextStrokePath (context);
	}
	//Now draw a circle 8 pixels radius from center (x_c, y_c)
	CGContextSetLineWidth (context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.75f);
	CGContextSetStrokeColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor purpleColor].CGColor);
	CGContextMoveToPoint (context, x_c, y_c);
	CGContextAddEllipseInRect(context, CGRectMake(x_c-4, y_c-4, 8, 8));
	CGContextFillEllipseInRect(context, CGRectMake(x_c-4, y_c-4, 8, 8));
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	//Stroke Path Now
	CGContextStrokePath (context);
}


- (void)dealloc {
    [super dealloc];
}


@end
