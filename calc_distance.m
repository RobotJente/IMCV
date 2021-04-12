function distance = calc_distance(buoyPixelLocation, principalPoint, focalLength)

dHorizontal = 5644;
dHorIm = 500;
h = 2.5;

oa1 = double(abs(principalPoint(2) - buoyPixelLocation(2)))/focalLength(2);
theta1 = atan(oa1);
oa2 = abs(principalPoint(2) - dHorIm)/focalLength(2);
theta2 = atan(oa2);
alpha = acos(h/dHorizontal);

theta = theta2-theta1;
phi = alpha - theta;

distance = tan(phi)*h
end
