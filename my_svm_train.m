function [model_file] = my_svm_train(training_file, c, gamma, indexes)
    if (nargin < 4)
        indexes = 1:12;
    end

    extract_features;
    save_groundtruths;
    load('features.mat');
    load('ground_truths.mat');
   
    
    features = [];
    ground_truths = [];
    f = fopen(training_file, 'w+');
    for i = indexes
        eval(sprintf('features_to_svm_data(f, features%d, ground_truth%d, [1:5])', i, i));
    end
    fclose(f);
    
    cmd = sprintf('svm-train -s 3 -t 2 -q -c %f -g %f %s', c, gamma, training_file);
    [status, cmdout] = system(cmd);
    if (status ~= 0)
        fprintf(1, 'svm train with c=%f g=%f file=%s  failed', c, gamma, training_file);
        model_file = ''
        return;
    end
    model_file = sprintf('%s.model',training_file);
end