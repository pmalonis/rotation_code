%% Plots histograms relative to all events

%clear all

sigma = .01;
winsize = 2;

nsubplots = 5; %subplots per page
fig_pos = [100,100,1000,1800];
figure_dir = '/home/pmalonis/nicho_rotation/firing_rates/';

pdf_merge = 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ pdfunite '; %merge command

% getting spikes from all sessions
data_dir = '/home/pmalonis/nicho_rotation/Proprioception_data/';
all_session_fr = [];
files = dir([data_dir '*.mat']);
events = {'Present', 'StartMove', 'MaxApp', 'Grasp', 'Retract'};


%%
for event = {'StartMove'}%events
    event=event{1};

%     for i = 1:length(files);
%         data_struct = load([data_dir files(i).name]);
%         spike_struct = perievent_spikes(data_struct, event);
% 
%         objects = unique({data_struct.Trials.Object});
%         session_fr = calc_fr(spike_struct, sigma, winsize, objects);
%         all_session_fr = [all_session_fr; session_fr];
% 
%         clear data_struct spike_struct session_fr;
%      end
    
    [~,I] = sort({all_session_fr.area});
    all_session_fr = all_session_fr(I);
    
    event_base = [figure_dir event];
    h = figure();
    set(h, 'Visible', 'Off');
    set(h, 'Position', fig_pos);
    for unit_idx = 1:length(all_session_fr)
        subplot(nsubplots, 1, mod(unit_idx-1,nsubplots)+1);
        shadedErrorBar(all_session_fr(unit_idx).time, all_session_fr(unit_idx).mean_fr,...
                        all_session_fr(unit_idx).sem_fr,'b');
        %plot(all_session_fr(unit_idx).time, all_session_fr(unit_idx).mean_fr)
        yl = ylim;
        title(['Unit ' num2str(unit_idx) ' (' all_session_fr(unit_idx).area ')']);
        %xlabel('Time Relative to Movement Onset(s)');
        ylabel('Spk/s');
        line([0,0],[0,yl(2)],'Color','r');
        if mod(unit_idx,nsubplots) == 0
            disp(unit_idx);
            filename = [event_base '_unit_' num2str(unit_idx,'%02d') '.pdf'];
            print(filename, '-dpdf');
            close(h)
            h = figure();
            set(h, 'Visible', 'Off');
            set(h, 'Position', fig_pos);            
        end
    end
    system([pdf_merge event_base '*.pdf ' event_base '.pdf']);
    system(['rm ' event_base '_unit_*.pdf'])
end

