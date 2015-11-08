function [frate,time] = smooth_spikes(spike_t, min_t, max_t, sig) 
    % Returns a gaussian-smoothed firing rate from spike event times in
    % seconds. Sig is the sigma parameter of the gaussian in seconds
    dt = 0.001; 
    time = min_t:dt:max_t;
    impulses = histcounts(spike_t, min_t:dt:max_t+dt);
    kern_cutoff = 4*sig;
    kern = normpdf(-kern_cutoff:dt:kern_cutoff, 0, sig);
    frate = conv(kern,impulses);
    start_idx = floor(length(kern)/2)+1;
    frate = frate(start_idx:start_idx + length(time) - 1);
end