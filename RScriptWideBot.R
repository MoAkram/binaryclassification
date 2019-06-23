library(data.table)
library(tidyverse)
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(scales)
library(class)

set.seed(1)
training <- fread("C:/Users/Moe.Akram/Desktop/training.csv")
validation <- fread("C:/Users/Moe.Akram/Desktop/validation.csv")

#binding train and validation df for column type conversion
fixDataType<-rbind(training,validation)

#preprocessing data for type conversion
fixDataType<-fixDataType[,variable1:=as.factor(variable1)]
fixDataType$variable2 <- gsub(',','.',fixDataType$variable2)
fixDataType$variable3 <- gsub(',','.',fixDataType$variable3)
fixDataType$variable8 <- gsub(',','.',fixDataType$variable8)
fixDataType$variable9 <- gsub('f','FALSE',fixDataType$variable9)
fixDataType$variable9 <- gsub('t','TRUE',fixDataType$variable9)
fixDataType$variable10 <- gsub('f','FALSE',fixDataType$variable10)
fixDataType$variable10 <- gsub('t','TRUE',fixDataType$variable10)
fixDataType$variable12 <- gsub('f','FALSE',fixDataType$variable12)
fixDataType$variable12 <- gsub('t','TRUE',fixDataType$variable12)
fixDataType$variable18 <- gsub('f','FALSE',fixDataType$variable18)
fixDataType$variable18 <- gsub('t','TRUE',fixDataType$variable18)
fixDataType$variable19 <- gsub('0','FALSE',fixDataType$variable19)
fixDataType$variable19 <- gsub('1','TRUE',fixDataType$variable19)
fixDataType$classLabel <- gsub('no.','FALSE',fixDataType$classLabel)
fixDataType$classLabel <- gsub('yes.','TRUE',fixDataType$classLabel)
fixDataType[fixDataType=="NA"]<-NA


#Column type conversions
fixDataType<-fixDataType[,variable2:=as.numeric(variable2)]
fixDataType<-fixDataType[,variable3:=as.numeric(variable3)]
fixDataType<-fixDataType[,variable8:=as.numeric(variable8)]
fixDataType<-fixDataType[,variable4:=as.factor(variable4)]
fixDataType<-fixDataType[,variable5:=as.factor(variable5)]
fixDataType<-fixDataType[,variable9:=as.logical(variable9)]
fixDataType<-fixDataType[,variable10:=as.logical(variable10)]
fixDataType<-fixDataType[,variable12:=as.logical(variable12)]
fixDataType<-fixDataType[,variable13:=as.factor(variable13)]
fixDataType<-fixDataType[,variable18:=as.logical(variable18)]
fixDataType<-fixDataType[,variable19:=as.logical(variable19)]
fixDataType<-fixDataType[,classLabel:=as.logical(classLabel)]

#renaming columns 17:19 to match their real position
names(fixDataType)[names(fixDataType)=="variable17"]<-"variable16"
names(fixDataType)[names(fixDataType)=="variable18"]<-"variable17"
names(fixDataType)[names(fixDataType)=="variable19"]<-"variable18"

#splitting train and validation df to their original ratios
training<-fixDataType[1:3700,]
validation<-fixDataType[3701:3900,]

#Initial Tree Model with 0.495 accuracy
tree <- rpart(classLabel~., training, method="class")
fancyRpartPlot(tree)
t_pred<-predict(tree,validation,type="class")
t_conf<-table(validation$classLabel,t_pred)
sum(diag(t_conf))/sum(t_conf)

#Removing last column from training set which is causing overfitiing
training$variable18<-NULL

#Second tree model with 0.835 accuracy
tree <- rpart(classLabel~., training, method="class")
fancyRpartPlot(tree)
t_pred<-predict(tree,validation,type="class")
t_conf<-table(validation$classLabel,t_pred)
sum(diag(t_conf))/sum(t_conf)

#prunning tree model based on least cross-validation error obtained from printcp, still 0.835 accuracy
tree <- rpart(classLabel~., training, method="class",cp=0.01)
fancyRpartPlot(tree)
t_pred<-predict(tree,validation,type="class")
t_conf<-table(validation$classLabel,t_pred)
sum(diag(t_conf))/sum(t_conf)

#attempting cross validation with 1/5 from training set as test set
shuffled_train<-training[sample(nrow(training))]
accs <- rep(0,6)
for (i in 1:6) {
  # These indices indicate the interval of the test set
  indices <- (((i-1) * round((1/6)*nrow(shuffled_train))) + 1):((i*round((1/6) * nrow(shuffled_train))))
  
  # Exclude them from the train set
  train <- shuffled_train[-indices,]
  
  # Include them in the test set
  test <- shuffled_train[indices,]
  
  # A model is learned using each training set
  tree <- rpart(classLabel ~ ., train, method = "class")
  
  # Make a prediction on the test set using tree
  pred<-predict(tree,test,type="class")
  
  # Assign the confusion matrix to conf
  conf<-table(test$classLabel,pred)
  
  # Assign the accuracy of this model to the ith index in accs
  accs[i] <- sum(diag(conf))/sum(conf)
}
#High mean of accuracy compared to actual accuracy of pruned tree,suggests overfitting due to lack of representative instances
mean(accs)