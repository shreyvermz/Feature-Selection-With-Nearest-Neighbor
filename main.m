function accuracy = leave_one_out_cross_validation(data, current_set, feature_to_add) 
    
   number_correctly_classified = 0;
   selected_features = [current_set, feature_to_add];

   % Ensure features don't exceed valid range
   selected_features = selected_features(selected_features <= size(data, 2) -1);

   for i = 1: size(data,1)
      
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


 
 function feature_search_demo(data)

   current_set_of_features = [3 28]; 
   best_overall_accuracy = 0;
   best_feature_set = [];

   fprintf('This dataset has %d features (not including the class attribute), with %d instances.\n', size(data,2)-1, size(data,1));
   fprintf('Running nearest neighbor with all features, using “leave-one-out” evaluation...\n');

   all_features_accuracy = leave_one_out_cross_validation(data, 1:size(data,2)-1, []);
   fprintf('Accuracy with all features: %.1f%%\n\n', all_features_accuracy * 100);
   
   fprintf('Beginning search...\n');

   for i = 1 : size(data,2) - 1

      fprintf('\nOn the %dth level of the search tree\n', i);
      feature_to_add_at_this_level = [9];
      best_so_far_accuracy = 0;

      for k = 1 : size(data,2)-1

         if isempty(intersect(current_set_of_features,k))
            temp_features = [current_set_of_features, k];
            fprintf('--Considering adding feature {%d}', k);
            
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
      fprintf('Feature set {%s} was best, accuracy is %.1f%%\n', num2str(current_set_of_features), best_so_far_accuracy * 100);

      if best_so_far_accuracy > best_overall_accuracy
         best_overall_accuracy = best_so_far_accuracy;
         best_feature_set = current_set_of_features;
      end
   end

   fprintf('\nFinished search!! The best feature subset is {%s}, which has an accuracy of %.1f%%\n', num2str(best_feature_set), best_overall_accuracy * 100);
end



data = load('CS170_Large_Data__58.txt');
feature_search_demo(data);
