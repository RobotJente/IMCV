% CALC_DISTANCE finds the distance between a matched template and the
% camera
%
% [distance] = CALC_DISTANCE(buoyPixelLocation, principalPoint, focalLength);
%
% @param buoyPixelLocation: pixel location of the buoy in the frame (found
% by template matching)
% @param focalLength: distance between lens and image plane of camera (pixels)
% @param principalPoint: the pixel value of the location where the optical
% axes intersect with the image plane
% @param dHorIm: pixel distance in y direction from the horizon to the object being
% tracked. 
% @param h: height of camera above the sea
function distance = calc_distance(buoyPixelLocation, principalPoint, focalLength, dHorIm, h)
    r = 6.371e6;                            % radius of the earth in meters
    dHorizontal = sqrt((r+h)^2 - r^2);      % straight line distance from camera 2.5 m above sea to horizon (meters)

    oa1 = double(abs(principalPoint(2) - buoyPixelLocation(2)))/focalLength(2);
    theta1 = atan(oa1);
    
    oa2 = abs(principalPoint(2) - dHorIm)/focalLength(2);
    theta2 = atan(oa2);
    
    alpha = acos(h/dHorizontal);

    theta = theta2-theta1;
    phi = alpha - theta;

    distance = tan(phi)*h;
end

