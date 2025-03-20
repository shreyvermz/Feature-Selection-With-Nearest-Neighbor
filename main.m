% https://www.mathworks.com/help/matlab/ref/fprintf.html used for formatting
function accuracy = leave_one_out_cross_validation(data, current_set, feature_to_add) 
    
   number_correctly_classified = 0;
   selected_features = [current_set, feature_to_add];

   % ensure features don't exceed valid range
   selected_features = selected_features(selected_features <= size(data, 2) -1);

   for i = 1: size(data,1)
      % zeroing out features
      object_to_classify = zeros(1, size(data,2)-1);
      object_to_classify(selected_features) = data(i, selected_features +1);
      label_object_to_classify = data(i, 1);

      nearest_neighbor_distance = inf;
      nearest_neighbor_label = -1;

      for k = 1 : size(data,1)
         
         if k ~= i

            neighbor = zeros(1, size(data,2)-1);
            neighbor(selected_features) = data(k, selected_features+1);

            distance = sqrt(sum((object_to_classify - neighbor).^2));

            if distance < nearest_neighbor_distance
               nearest_neighbor_distance = distance;
               nearest_neighbor_label = data(k, 1);
            end
         end
      end

      if label_object_to_classify == nearest_neighbor_label
         number_correctly_classified = number_correctly_classified + 1;
      end
   end

   accuracy = number_correctly_classified / size(data,1);

end


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function feature_search_demo(data)

   current_set_of_features = []; 
   best_overall_accuracy = 0;
   best_feature_set = [];

   fprintf('This dataset has %d features (not including the class attribute), with %d instances.\n', size(data,2)-1, size(data,1));
   fprintf('Running nearest neighbor with all features, using “leave-one-out” evaluation...\n');

   all_features_accuracy = leave_one_out_cross_validation(data, 1:size(data,2)-1, []);
   fprintf('Accuracy with all features: %.1f%%\n\n', all_features_accuracy * 100);
   
   fprintf('Beginning search...\n');

   accuracy = leave_one_out_cross_validation(data, current_set_of_features, []);
   fprintf(' --> Accuracy of empty set is %.1f%%\n', accuracy * 100);

   for i = 1 : size(data,2) - 1

      fprintf('\nOn the %dth level of the search tree\n', i);
      feature_to_add_at_this_level = [];
      best_so_far_accuracy = 0;

      %accuracy = leave_one_out_cross_validation(data, current_set_of_features, []);
      %fprintf(' --> Accuracy of empty set is %.1f%%\n', accuracy * 100);

      for k = 1 : size(data,2)-1

         if isempty(intersect(current_set_of_features,k))
            temp_features = [current_set_of_features, k];
            fprintf('Using feature {%d}', k);
            
            accuracy = leave_one_out_cross_validation(data, temp_features, []);
            fprintf(' --> Accuracy is %.1f%%\n', accuracy * 100);

            if accuracy > best_so_far_accuracy
               best_so_far_accuracy = accuracy;
               feature_to_add_at_this_level = k;
            end
         end
      end

      if isempty(feature_to_add_at_this_level)
         break;
      end

      current_set_of_features = [current_set_of_features, feature_to_add_at_this_level];
      fprintf('Feature set {%s} was best choice, accuracy is %.1f%%\n', num2str(current_set_of_features), best_so_far_accuracy * 100);

      if best_so_far_accuracy > best_overall_accuracy
         best_overall_accuracy = best_so_far_accuracy;
         best_feature_set = current_set_of_features;
      end
   end

   fprintf('\nFinished forward search!! The best feature subset is {%s}, which has an accuracy of %.1f%%\n', num2str(best_feature_set), best_overall_accuracy * 100);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function feature_search_demo_backward(data)

   current_set_of_features = 1:(size(data, 2) - 1);
   best_so_far_accuracy = 0;
   best_set_of_features = current_set_of_features; 
   
   fprintf('This dataset has %d features (not including the class attribute), with %d instances.\n', size(data,2)-1, size(data,1));
   fprintf('Running nearest neighbor with all features, using “leave-one-out” evaluation...\n');

   all_features_accuracy = leave_one_out_cross_validation(data, current_set_of_features, []);
   fprintf('Accuracy with all features: %.1f%%\n\n', all_features_accuracy * 100);

   fprintf('Beginning backward elimination search \n');
   all_features_accuracy = leave_one_out_cross_validation(data, 1:size(data,2)-1, []);
   fprintf('Accuracy with all features: %.1f%%\n\n', all_features_accuracy * 100);
   % keep going till only one feature left
   while length(current_set_of_features) > 1  

       fprintf('\nOn the %d-feature set level of the search tree\n', length(current_set_of_features));
       feature_to_remove_at_this_level = [];
       % we want worst accuracy instead of best
       worst_so_far_accuracy = inf;  

       for k = 1:length(current_set_of_features)
           % remove feature rather than add
           temp_features = current_set_of_features(current_set_of_features ~= current_set_of_features(k));
           fprintf('Considering removing feature {%d}', current_set_of_features(k));
           
           accuracy = leave_one_out_cross_validation(data, temp_features, []);  
           fprintf(' --> Accuracy is %.1f%%\n', accuracy * 100);

           % track worst accuracy vs best
           if accuracy < worst_so_far_accuracy
               worst_so_far_accuracy = accuracy;
               feature_to_remove_at_this_level = current_set_of_features(k);
           end
       end

       % get rid of least accurate feature
       current_set_of_features = current_set_of_features(current_set_of_features ~= feature_to_remove_at_this_level);
       fprintf('Feature set {%s} was best, accuracy is %.1f%%\n', num2str(current_set_of_features), worst_so_far_accuracy * 100);

       % Track the best feature set found so far
       if worst_so_far_accuracy > best_so_far_accuracy
           best_so_far_accuracy = worst_so_far_accuracy;
           best_set_of_features = current_set_of_features;
       end
   end

   fprintf('\nFinished backward elimination! The best feature subset is {%s}, with accuracy: %.1f%%\n', num2str(best_set_of_features), best_so_far_accuracy * 100);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function main_handler()

   % Prompt user for selection method
   disp('Welcome to Shrey Vermas Feature Selection Algorithm.');
   disp('Enter the filename of the dataset: ')
   filename = input('Enter the filename of the dataset: ', 's');
   data = load(filename);
   disp('Choose Feature Selection Method:');
   disp('1. Forward Selection');
   disp('2. Backward Elimination');
   choice = input('Enter 1 or 2: ');

   if choice == 1
       disp('Running Forward Selection...');
       feature_search_demo(data);  
   elseif choice == 2
       disp('Running Backward Elimination...');
       feature_search_demo_backward(data);  
   else
       disp('Invalid choice. Please restart and enter 1 or 2.');
   end
   
end

main_handler();