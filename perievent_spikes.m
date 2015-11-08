function result = perievent_spikes(data_struct, event)
%Obtains spikes relative to trial event for Jameson data
%      result = perievent_spikes(data_struct, event) returns the
%      spiking data from data_struct, with spike times relative to event 
%      (a string). 
%
%      result = perievent_spikes(data_struct, event, objects) returns the 
%      data for trials in which the subject grasps an object in objects
%      (where objects is a cell array of strings containing the desired
%      trial objects).

% Returns:
% result: n-by-1 struct where n is the number of "good" units in target
% areas. The field 'area' contains the cortical area of the unit. The field
% 'electrode' is the electrode number on which the unit was recorded. The
% field 'trials' is a k-by-1 struct, where k is the number of trials
% recorded for that unit. The fields of the 'trials' struct are 'object',
% which contains the object grasped on that trial, and 'spikes,' which
% contains the spike times in seconds for that trial.

unit_idx = get_unit_idx(data_struct); % index of good units in target areas
                                      % in spike cell array

n_units = length(unit_idx);

all_units = data_struct.ArrayInfo.Electrodes;
target_struct = rmfield(data_struct.ArrayInfo.TargetElectrodes, 'cutaneous'); 
areas = fieldnames(target_struct);

%These three cell arrays contain the data that will go in the result struct 
area_labels = cell(n_units,1);
output_trials = cell(n_units, 1);
electrodes = mat2cell(all_units(unit_idx,1), ones(n_units,1));
for i = 1:n_units
    % finding area of electrode
    for area = areas'
        area = area{1};
        area_electrodes = target_struct.(area);
        if isempty(area_electrodes)
            continue
        elseif any(area_electrodes(:,1) == all_units(unit_idx(i),1))
            area_labels{i} = area;
            break
        end
    end
    assert(~isempty(area_labels{i})) %making sure area for unit was found
    
    %getting trial spikes and objects
    output_objects = {data_struct.Trials.Object}';
    spikes = cell(length(data_struct.Trials),1);
    for trial_idx = 1:length(data_struct.Trials)
        trial = data_struct.Trials(trial_idx);
        t_event = trial.Events.(event);
        trial_spikes = trial.Spikes.Timestamps{i} - t_event; %taken relative to event
        spikes{trial_idx} = trial_spikes;
    end
    output_trials{i} = struct('object', output_objects, 'spikes', spikes);
end

[~,I] = sort(area_labels); %sorting according to area name
result = struct('trials', output_trials(I), 'area', area_labels(I),...
                'electrode', electrodes(I)); % output struct


end


