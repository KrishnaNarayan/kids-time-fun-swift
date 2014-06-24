//
//  SetClockView.m
//  KidsTimeFun
//
//  Created by Jagmeet Chawla on 4/19/09.
//  Modified by SVV Satyanarayana, under contract to NSC Partners LLC on 28/04/10.
//  Copyright 2009-2013 NSC Partners LLC. All rights reserved.
//

#import "SetClockView.h"
#import "KidsTimeFunAppState.h"

@implementation SetClockView

@synthesize hours;
@synthesize minutes;
@synthesize showMinutesOffsetInHoursHand;

//Macros to convert hours, minutes and seconds to angles in radians
#define hoursToRadiansHM(h, m) ((M_PI/2)-(((h*2*M_PI)/12)+((m/60)*(0.75*2*M_PI/12))))
#define hoursToRadiansH(h) ((M_PI/2)-((h*2*M_PI)/12))
#define minutesToRadians(m) ((M_PI/2)-((m*2*M_PI)/60))
#define secondsToRadians(s) ((M_PI/2)-((s*2*M_PI)/60))

#define radiansToHours(theta_h) ((theta_h*6)/M_PI)
#define radiansToMinutes(theta_m) ((theta_m*30)/M_PI)
//Some convenience macros
#define smallerOf(a, b) a<b?a:b
#define greaterOf(a, b) a>b?a:b

//-(float)hours
//{
//    return round(hours);
//}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		hourHandFlag = NO;		
		minuteHandFlag = NO;
		firstPass = YES;
		hours = 12;
		minutes = 30;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Clock Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext ();	// Get current graphics context
	//initialize radial coordinates
	//float r = 0.0f, theta = 0.0f;
	//initialize cartesian coordinates
	float x_0 = 0.0f, y_0 = 0.0f;	//Origin
	float x = 0.0f, y = 0.0f;		//coordinates
	//float x_c = 0.0f, y_c = 0.0f;	//center
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
	UIImage *img = [UIImage imageNamed:@"ClockFace218.png"]; //Load clock face image
	//Draw clock face - with diameter
	[img drawInRect:CGRectMake(x, y, d, d)];
	
	//initialize hours to 12 and minutes to 15
	//self.hours = 12;
	//self.minutes = 30;
	self.showMinutesOffsetInHoursHand = NO;
	
	//Now draw hours hand
	//Get radial coordinates
	//float r_h = 0.0f;	//initialize radius for the hand
	r_h = r*0.65;	//65% of the clock face radius - it is smallest hand
	//Now load angle based on the hours
	if (showMinutesOffsetInHoursHand)
		theta_h = hoursToRadiansHM(self.hours, self.minutes);
	else
		theta_h = hoursToRadiansH(self.hours);
	
	//Convert to cartesian - remember in CorGraphics y coordinate is reversed (-y)
	//And also it's origin will be the center of clock i.e. x_c, y_c
	x = r_h * cos(theta_h);
	y = -1 * r_h * sin(theta_h);
	//now convert these to coordinates from origin x_0, y_0
	x = x+x_c;
	y = y+y_c;
		
	if (hourHandFlag && !firstPass) {
		theta = atan2(x_c-xx,yy-y_c)+M_PI/2;	//This gets the phasing correct
		x = r*0.65 * cos(theta)+x_c;
		y = r*0.65 * sin(theta)+y_c;
		float correctedHourTheata = theta+(M_PI/2);
		self.hours = radiansToHours(correctedHourTheata);
	}
	
		//NSLog(@"%f %f %f %f",x_c,y_c,x,y);
	//Now draw a line 3 pixels wide from center (x_c, y_c) to the above point (x, y)
	CGContextSetLineWidth (context, 7.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 1.0f);
	CGContextSetStrokeColorWithColor (context, [UIColor blueColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor blueColor].CGColor);
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	CGContextMoveToPoint (context, x_c, y_c);
	xHourHand = x;
	yHourHand = y;
	CGContextAddLineToPoint (context, x, y);
	//Stroke Path Now
	CGContextStrokePath (context);
	/*
	//now draw a circle here with the radius of 20 pixels for dragging
	CGContextSetLineWidth (context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.50f);
	CGContextSetStrokeColorWithColor (context, [UIColor blueColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor blueColor].CGColor);	
	CGContextFillEllipseInRect(context, CGRectMake(x-20, y-20, 40, 40));
	CGContextSetLineWidth (context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.75f);
	CGContextSetStrokeColorWithColor (context, [UIColor blueColor].CGColor);
	CGContextAddEllipseInRect(context, CGRectMake(x-20, y-20, 40, 40));
	CGContextStrokePath (context);	
	*/
	//Now minutes hand
	//Get radial coordinates
	//float r_m = 0.0f;
	r_m = r*0.80;
	theta_m = minutesToRadians(self.minutes);
	//Convert to cartesian - remember in CorGraphics y coordinate is reversed (-y)
	//And also it's origin will be the center of clock i.e. x_c, y_c
	x = r_m * cos(theta_m);
	y = -1 * r_m * sin(theta_m);
	//now convert these to coordinates from origin x_0, y_0
	x = x+x_c;
	y = y+y_c;
	
	if (minuteHandFlag && !firstPass) {
		theta = atan2(x_c-xx,yy-y_c)+M_PI/2;	//This gets the phasing correct
		x = r*0.85 * cos(theta)+x_c;
		y = r*0.85 * sin(theta)+y_c;
		float correctedMinutesTheta = theta + (M_PI/2);
		self.minutes = radiansToMinutes(correctedMinutesTheta);
		self.minutes = (self.minutes == 60.0 ? 59.99 : self.minutes);
	}
	
	//Krishna added the following two lines
	//self.hours = round(self.hours);
    self.minutes = (round(self.minutes) == 60 ? 00 : round(self.minutes));
	
		//NSLog(@"Time is %f:%f",self.hours,self.minutes);
	//Now draw a line 3 pixels wide from center (x_c, y_c) to the above point (x, y)
	CGContextSetLineWidth (context, 5.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 1.0f);
	CGContextSetStrokeColorWithColor (context, [UIColor greenColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor greenColor].CGColor);
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	CGContextMoveToPoint (context, x_c, y_c);
	xMinuteHand = x;
	yMinuteHand = y;
	CGContextAddLineToPoint (context, x, y);
	//Stroke Path Now
	CGContextStrokePath (context);
	//now draw a circle here with the radius of 20 pixels for dragging
	/*
	CGContextSetLineWidth (context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.50f);
	CGContextSetStrokeColorWithColor (context, [UIColor greenColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor greenColor].CGColor);	
	CGContextFillEllipseInRect(context, CGRectMake(x-20, y-20, 40, 40));
	CGContextSetLineWidth (context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 0.75f);
	CGContextSetStrokeColorWithColor (context, [UIColor greenColor].CGColor);
	CGContextAddEllipseInRect(context, CGRectMake(x-20, y-20, 40, 40));
	CGContextStrokePath (context);
	*/
	//Now draw a circle 8 pixels radius from center (x_c, y_c)
	CGContextSetLineWidth (context, 2.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetAlpha(context, 1.0f);
	CGContextSetStrokeColorWithColor (context, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor (context, [UIColor blackColor].CGColor);
	CGContextMoveToPoint (context, x_c, y_c);
	CGContextAddEllipseInRect(context, CGRectMake(x_c-4, y_c-4, 8, 8));
	CGContextFillEllipseInRect(context, CGRectMake(x_c-4, y_c-4, 8, 8));
	CGContextSetShadow(context, CGSizeMake(1.0f, 1.0f), 1.0f);
	//Stroke Path Now
	CGContextStrokePath (context);
	
	firstPass = NO;
    
    if (self.hours == 12.0) {
        self.hours = 0;
    }
    NSLog(@"%f",self.hours);

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// touches is an NSSet.  Take any single UITouch from the set
	UITouch *touch = [touches anyObject];

	xx = [touch locationInView:self].x;		//Get touch location
	yy = [touch locationInView:self].y;
	
	//r_m = sqrt(xx * xx + yy * yy);		//Used only for testing

//	xx = r*0.60 * cos(theta)+x_c;
//	yy = r*0.60 * sin(theta)+y_c;
//NSLog(@"TOUCH Moved");
	
	[self setNeedsDisplay];
}
	
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

		hourHandFlag = NO;
		minuteHandFlag = NO;
	//NSLog(@"TOUCH ENDED");

}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	UITouch *touch = [touches anyObject];
	
	xx = [touch locationInView:self].x;		//Get touch location
	yy = [touch locationInView:self].y;	
	NSLog(@"TOUCH Began");
	thetaTouch = atan2(yy-y_c, xx-x_c);
	thetaHoursHand = atan2(yHourHand-y_c,xHourHand-x_c);
	thetaMinutesHand = atan2(yMinuteHand-y_c,xMinuteHand-x_c);
	NSLog(@"Touch %2.2f, Hours %2.2f, Minutes %2.2f",thetaTouch,thetaHoursHand,thetaMinutesHand);
	if (fabs(thetaTouch-thetaHoursHand) < fabs(thetaTouch -thetaMinutesHand))   {
		NSLog(@"Closer to Hours Hand");
		hourHandFlag = YES;
		minuteHandFlag = NO;
	}
	else {
		NSLog(@"Closer to Minutes Hand");
		hourHandFlag = NO;
		minuteHandFlag = YES;
	}

	
}


- (void)dealloc {
    [super dealloc];
}


@end
