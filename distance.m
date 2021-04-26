function distance = distance(buoyPixelLocation, principalPoint, focalLength)

dHorizontal = 5644;
dHorIm = 500;
h = 2.5;

theta1 = atan(abs(principalPoint(2) - buoyPixelLocation(2))/focalLength(2));
theta2 = atan(abs(principalPoint(2) - dHorIm)/focalLength(2));
alpha = acos(h/dHorizontal);

theta = theta2-theta1;
phi = alpha - theta;

distance = tan(phi)*h
end
