function  result = calc_fr(spike_struct, sigma, winsize, objects)

% result = calc_histogram(spike_struct, binsize)
%   Computes the firing rate of spiking data in spike_struct
%   (the output of perievent_spikes), using gaussian smoothing with sigma paramater
%   "sigma", for spike times in a window winsize seconds long centered on 0. 
%   The function computes the histogram using only trials in which the subject 
%   grasps an object in objects
%   (where objects is a cell array of strings containing the desired
%   trial objects).

n_units = length(spike_struct);

% These cell arrays will contain the data in the output struct
area_labels = {spike_struct.area}';
electrodes = {spike_struct.electrode}';
mean_fr = cell(n_units,1);
sem_fr = cell(n_units,1);
time = cell(n_units,1);

for unit_idx = 1:n_units
    n = 1; %trial counter
    for trial_idx = 1:length(spike_struct(unit_idx).trials)
        trial_object = spike_struct(unit_idx).trials(trial_idx).object;
        if ~isempty(cell2mat(strfind(objects, trial_object)))
            trial_spikes = spike_struct(unit_idx).trials(trial_idx).spikes;
            if n==1
                sum_rate = smooth_spikes(trial_spikes, -winsize./2, winsize./2, sigma); %initialize 
                sum_sqr_rate = sum_rate.^2;
            else
                trial_rate = smooth_spikes(trial_spikes, -winsize./2, winsize./2, sigma);
                sum_rate = sum_rate + trial_rate;
                sum_sqr_rate = sum_sqr_rate + trial_rate.^2; 
            end
            n = n + 1;
        end
    end
    mean_fr{unit_idx} = sum_rate./n;
    sem_fr{unit_idx} = sqrt((sum_sqr_rate - (sum_rate.^2)./n)./(n-1))/sqrt(n);
    [~,time{unit_idx}] = smooth_spikes(trial_spikes, -winsize./2, winsize./2, sigma);
end

result = struct('mean_fr', mean_fr, 'sem_fr', sem_fr,... 
                'time', time, 'area', area_labels,'electrode', electrodes); % output struct

end