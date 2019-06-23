# Binary Classification
# Thought process
# Data Discovery:
Upon intial inspection of training dataset I had few notes that were quite apparent:
  1-Column names are ambigious.
  2-numerical data formatted using "," instead of "."
  3-multiple columns containing logical data in multiple formats like yes.,1 and t for TRUE though I couldn't be sure due to absence of       data context.
  4-Also I noticed almost 100% correlation between the last column and classlabel which normally indicates that the produced model will be     overfit or that the last column will be an excellent if not the only predictor of classlabel.
  5-Intially I thought I should use a Binary Decision Tree or KNN for the training model but as I discovered the data more KNN became an       infesiable solution as I decided that the NA values cannot be fully omitted or imputted due to absense of context. 
  
# Data Preprocessing
Normally I would follow Tidyverse guidelines for data preprocessing but due to absense of data context this proved to be a challenging     task so I decided to proceed based on intuition; I imported the training and validation datasets using data.table package, binded them in one dataframe and reformatted them as below:
  1-Reformat all numerical columns by replacing ',' by '.'.
  2-Reformat all logical columns to be TRUE, FALSE or NA.
  3-Check all char columns to check if they're applicable to be formatted as a factor and change column types accordingly.
  4-Upon further insepction and multiple plots drawn I decided not to manipulate the dataset based on missing values or extreme values as     I simply cannot judge them based on context.
  
# Model Building
I decided to use Binary Decision Tree for my model as it will be able to ignore/handle missing data during model building, At this point I am not 100% sure this is the optimal option but still I decided to proceed based on intuition and my current knowledge, I decided to use percision based on a confusion matrix as my preformance indicator, ROCR visualization options such as 'auc' would have been a good indicator also but I thought it's a bit of an overkill(hopefully I am right), the algorithm produced the below results when tested against the validation dataset and 0.2 test dataset obtained from training dataset:
  1-Initial tree accuracy was 99% on test dataset and 49.5% on validation dataset which indicates overfitting,Tree was using only 1          column as indicator due to it's high variance .
  2-I omitted the column causing high variance and an 11 level tree was produced, the new tree had 83% accuracy on validation dataset 97%     on test dataset, still indicating overfit data.
  
 at this point I attempted to prune the tree on cp value of 0.01 obtained from calculating the cross validation error but still the same 83% accuracy, I also attempted to cross-validate the training data using 5 folds which produced a mean of 97% accuracy against the test dataset confirming the overfit hypothesis.
 
 #Conclusion
 At this point I am left with the conclusion that 83% is the maximum accuracy that can be produced training a model against this data or that the training data simply isn't a good representor of the the validation data and that this the main reason overfitting occurs or that I am simply missing something and there're multiple other algorithms or performance indicators that can produce better results.
