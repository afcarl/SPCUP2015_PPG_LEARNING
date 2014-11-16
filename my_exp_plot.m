logC_s = 11;
logC_b = 11;
logC_step = 2;
logG_s = -9;
logG_b = -9;
logG_step = 2;

results = [];
for logC = logC_s : logC_step : logC_b
    for logG = logG_s : logG_step : logG_b
        c = 2048; %2^logC;
        gamma = 0.00625;%2^logG;
        
        
        extract_features;
        save_groundtruths;
        load('features.mat');
        load('ground_truths.mat');
        indexes_all = 1:12;

        f = fopen(sprintf('exp\\results_%f_%f.txt', c, gamma), 'w+');
        fprintf(1, 'c=%f, g=%f\n', c, gamma);
 
        corr_sum = 0;
        aae_sum = 0;

        for i = 1:12
            fprintf(1, '\nTest %d\n', i);
            train_idxes = indexes_all( ~ismember( indexes_all, i ) );
            training_file = sprintf('exp\\my_train_no_%d', i);
            predict_file = sprintf('exp\\my_predict_%d', i);
            output_file = sprintf('exp\\my_out_%d', i);
            fig_file = sprintf('plot_%d', i);
      
            model_file = my_svm_train(training_file, c, gamma, train_idxes);
            [mse_predict, corr_predict] = my_svm_predict(model_file, predict_file, output_file, i);
            [~, ~, output_file_track] = my_mod_track(predict_file, output_file);
            [mse_track, corr_track, aae_track] = my_calc_results(predict_file, output_file_track);
            mse = mse_track;
            corr = corr_track;
            avg_abs_err = aae_track;
            
            my_plot_func(predict_file, output_file_track, fig_file);

            fprintf(f, 'predict %d:mse = %f , corr = %f\n', i, mse_predict, corr_predict);
            fprintf(f, 'tracked %d:mse = %f , corr = %f , avg_abs_err = %f\n', i, mse_track, corr_track, aae_track);    
            
            fprintf(1, 'result : mse %f , corr %f , avg_abs_err = %f\n', mse, corr, avg_abs_err);
            corr_sum = corr_sum + corr;
            aae_sum = aae_sum + avg_abs_err;
        end

        fprintf(1, 'c = %f, gamma = %f,  Average corr = %f\n', c, gamma, corr_sum / 12);
        fprintf(f, 'c = %f, gamma = %f,  Average corr = %f\n', c, gamma, corr_sum / 12);
        fprintf(1, 'c = %f, gamma = %f,  Average abs error = %f BPM\n', c, gamma, aae_sum / 12);
        fprintf(f, 'c = %f, gamma = %f,  Average abs error = %f BPM\n', c, gamma, aae_sum / 12);
        fclose(f);

    end
end
