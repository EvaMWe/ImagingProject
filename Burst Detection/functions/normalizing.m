function [norm] = normalizing(data)

n_frames = data.frames;
x = 1:1:n_frames;
x_norm = x./n_frames;
x_norm = x_norm';

y = data.base;
y_max = max(y);
y_norm = y./y_max;

norm.y=y_norm;
norm.x=x_norm;
norm.ymax=y_max;
norm.xmax=n_frames;

end

