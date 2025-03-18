 function accuracy = leave_one_out_cross_validation(data, current_set, feature_to_add) 
    accuracy = rand; % go to 6:50 in video to see what this is
 end 

 
function feature_search_demo(data)

   for i = 1 : size(data,2) - 1
      disp(['On the ', num2str(i), 'th level of the search tree'])
   end

end

data = load('CS170_Small_Data__39.txt');
feature_search_demo(data);
