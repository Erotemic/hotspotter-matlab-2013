function [scale] = radius2scale(radius)

%After Six Sigma virtually nothing will have an effect.
scale = radius ./ 6;
