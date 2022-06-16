function [H] = generate_homog(x1s,x2s)

numpts = size(x1s,2);

%Add homoginizing dimension if it doesn't exist
if size(x1s,1) == 2
  x1s = [x1s; ones(1,numpts)];
  x2s = [x2s; ones(1,numpts)];
end

if numpts < 4
  H = eye(3);
  return 
end
  x1st = x1s';
  Mbynine = zeros(2*numpts,9);
  for i = 1:numpts
    u2 = x2s(1,i);
    v2 = x2s(2,i);
    %%Concatinate all 2x9 matrices into an Mx9 matrix
    Mbynine(i*2-1:i*2,:)  = [0  0  0    -x1st(i,:)   v2*(x1st(i,:))   ;
                             x1st(i,:)  0   0   0   -u2*(x1st(i,:))] ;
  end

  %% h is the right nullspace of Mbynine
  % This should be the equivilant of null(Mbynine)
  % but for some reason that sometimes doesn't work
  [~, ~, V] = svd(Mbynine);
  h = V(:,end)  ; 

  %h = null(Mbynine);
  %% turn h into H
  H = [transpose(h(1:3,1)); transpose(h(4:6,1)) ; transpose(h(7:9,1))];

