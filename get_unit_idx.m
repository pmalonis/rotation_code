function unit_idx = get_unit_idx(data_struct)
%Obtains the index of units that are both in target areas and "good,"
%according to the data_struct used for Jameson data.
%Returns:
% unit_idx: A vector of indices that can be used to extract spike times
% from data_struct.Trials(i).Spikes.Timestamps

target_struct = rmfield(data_struct.ArrayInfo.TargetElectrodes, 'cutaneous');
target_electrodes = cell2mat(struct2cell(target_struct));
all_electrodes = data_struct.ArrayInfo.Electrodes;
good_units = ~any(bsxfun(@eq, all_electrodes(:,2),[0,255]),2); % 0 and 255
                                                                % are the codes for bad units
target_units = any(bsxfun(@eq, all_electrodes(:,1), target_electrodes(:,1)'),2);
unit_idx = find(target_units & good_units); %units that will be used

%assert(length(unit_idx) == sum(target_electrodes(:,2))); % making sure unit count from 
                                                        %Arrayinfo.Electrodes
                                                        %and %ArrayInfo.TargetElectrodes is the same
end