 function accuracy = leave_one_out_cross_validation(data, current_set, feature_to_add) 
    
   number_correctly_classified = 0;

   for i = 1: size(data,1)
      
      object_to_classify = data(i,2:end);
      label_object_to_classify = data(i, 1);

      nearest_neighbor_distance = inf;
      nearest_neighbor_location = inf;

      for k = 1 : size(data,1)
         
         if k ~= i

            distance = sqrt(sum((object_to_classify - data(k,2:end)).^2));

            if distance < nearest_neighbor_distance

               nearest_neighbor_distance = distance;
               nearest_neighbor_location = k;
               nearest_neighbor_label = data(nearest_neighbor_location,1);
            end
         end
      end

      if label_object_to_classify == nearest_neighbor_label;
         number_correctly_classified = number_correctly_classified + 1;
      end
   end

   accuracy = number_correctly_classified / size(data,1);

 end 

 
function feature_search_demo(data)

   current_set_of_features = []; 

   for i = 1 : size(data,2) - 1

      disp(['On the ', num2str(i), 'th level of the search tree'])
      feature_to_add_at_this_level = [];
      best_so_far_accuracy = 0;

      for k = 1 : size(data,2)-1

         if isempty(intersect(current_set_of_features,k))
         disp(['--Considering adding the ', num2str(k), 'feature'])
         accuracy = leave_one_out_cross_validation(data,current_set_of_features, k+1);

         if accuracy > best_so_far_accuracy
            best_so_far_accuracy = accuracy;
            feature_to_add_at_this_level = k;
         end
       end
      end

   current_set_of_features(i) = feature_to_add_at_this_level;
   disp(['On level ', num2str(i), ' i added feature ', num2str(feature_to_add_at_this_level), ' to current set'])

   end

end

data = load('CS170_Small_Data__39.txt');
feature_search_demo(data);
