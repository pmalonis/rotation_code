%% Plots histograms relative to all events


sigma = 10;
winsize = 2;
bins = [-winsize/2:binsize:winsize/2-binsize] * 1000; %bin centers, in miliseconds
data_struct = session24;
events = fieldnames(data_struct.Trials(1).Events);
events = {events{2:end-1}};
objects = unique({session24.Trials.Object});

nsubplots = 10; %subplots per page
event = events{1};
figure_dir = '/home/pmalonis/nicho_rotation/histograms/';
pdf_merge = 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/ pdfunite '; %merge command

%for event = events

    %event=event{1};
    
    spike_struct = perievent_spikes(data_struct, event);
    all_object_fr = calc_fr(spike_struct, sigma, winsize, objects);
    event_base = [figure_dir event];
    for unit_idx = 1%:length(spike_struct)
        h = figure();
        set(h, 'Visible', 'Off');
        set(h, 'Position', [100,100,1000,1500]);
        subplot(nsubplots, 1, 1);
        bar(bins, all_object_hist(unit_idx).histogram);
        yl = ylim;
        line([0,0],[0,yl(2)])
        title('All Objects')
        fig_idx = 2;
        filename_base = [event_base '_unit_' num2str(unit_idx)]; 
        for obj_idx = 1:length(objects)
            subplot(nsubplots, 1, fig_idx)
            obj_hist = calc_fr(spike_struct, binsize, winsize, {objects{obj_idx}});
            bar(bins, obj_hist(unit_idx).histogram);
            yl = ylim;
            line([0,0],[0,yl(2)])
            title([objects{obj_idx} ' (' obj_hist(unit_idx).area ')']);
            if fig_idx == nsubplots
                filename = [filename_base '_' num2str(obj_idx,'%02d') '.pdf']; 
                print(filename, '-dpdf')
                close(h);
                h = figure();
                set(h, 'Visible', 'Off');
                set(h, 'Position', [100,100,1000,12000]);
                fig_idx = 1;
            end
            fig_idx = fig_idx + 1;
        end
        system([pdf_merge filename_base '*.pdf ' filename_base '.pdf']);
        %system(['rm ' filename_base '_*.pdf']);
    end