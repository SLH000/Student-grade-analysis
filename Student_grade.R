library(mongolite)
library(tidyverse)
library(tidyr)
library(ggplot2)

#Connect to the database 
connection_string = 'mongodb+srv://k07aa5:k07aa5@comp8031.5es0wna.mongodb.net/?retryWrites=true&w=majority'

#Loading the data from Mongodb
student_collection <- mongo(collection="grades", db="sample_training", url=connection_string)

#Retrieve Data from MongoDB
student_collection$count()
student_collection$iterate()$one()
student_collection$find(limit = 10)

#Data Transformation 
result <- student_collection$find()
student_tb <- as.tibble(result)
head(student_tb)
grades_tibble <- unnest_wider(student_tb, scores) %>% unnest(c(type, score))


# Pivot the data to wide format with separate columns for each assessment type
grades11<- pivot_wider(grades_tibble, names_from = type, values_from = score, names_prefix = "score_")
head(grades11) 

grades11 <- grades11 %>% unnest(c(score_exam, score_quiz))
grades11 <- grades11 %>%separate(score_homework, into = c("homework_1", "homework_2"), sep = ",")
grades11 <- grades11 %>% mutate(homework_1 = as.numeric(sub("c\\((.*)", "\\1", homework_1)))
grades12 <- grades11 %>% mutate(homework_2 = gsub("\\)", "", homework_2))
grades13 <- grades12 %>% mutate(homework_2 = as.numeric(gsub("\\s", "", homework_2)))

# check is there any NA in the tibble
sum(is.na(grades13))

#Calculate the homewoek mean and overall course grade 
grades13$homework_mean <- rowMeans(grades13[ , c(5,6)], na.rm = TRUE)
grades13$coursegrade <- rowMeans(grades13[ ,c(3:6)], na.rm = TRUE)

grades14 <- grades13 %>%
  mutate(final_grade = case_when(
    coursegrade > 90 ~ "A",
    coursegrade > 80 ~ "B",
    coursegrade > 70 ~ "C",
    coursegrade > 60 ~ "D",
    coursegrade > 50 ~ "E",
    TRUE ~ "F"))

#Data Visualization 
# Stacked bar plot of the Type - categorical vs categorical
sub_grade_2 <- subset(grades_tibble, class_id <=30)
plot_1 <- ggplot(sub_grade_2, aes(x = factor(class_id), fill = factor(type))) +
  geom_bar(position = "fill") +
  labs(x = "Class ID", y = "Proportion", title = "Categorical vs Categorical Variable") +
  scale_fill_discrete(name = "Type")

# Stacked bar chart of Course grade in each class - categorical vs categorical
plot_2 <- ggplot(grades14, aes(x = class_id, fill = final_grade)) +
  geom_bar() +
  labs(x = "Class ID", y = "Count", title = "Course Grade Distribution by Class ID")

# Histogram of exam scores - categorical vs numerical
sub_grade_500 <- subset(grades13, class_id==500)

plot_3 <- ggplot(sub_grade_500, aes(x = score_exam)) +
  geom_histogram(binwidth = 5, fill = "blue", color = "white") +
  labs(x = "Exam Score", y = "Frequency", title = "Histogram of Exam Scores of class ID 500")

#Box boxplot of the exam score - categorical vs numerical variable
sub_grade_30 <- subset(grades13, class_id <=30)
plot_4 <- ggplot(sub_grade_30, aes(x = factor(class_id), y = score_exam)) +
  geom_boxplot(fill = "blue", color = "black") +
  labs(x = "Class ID", y = "Exam Score", title = "Categorical vs Numerical Variable")

# Bar plot of quiz scoare - categorical vs numerical variable
plot_5 <- ggplot(sub_grade_30, aes(x = factor(class_id), y = score_quiz)) +
  geom_bar(stat = "summary", fun = "mean", fill = "blue", color = "black") +
  labs(x = "Class ID", y = "Mean Exam Score", title = "Bar Plot of Categorical vs Numerical Variable") 

# Scatter plot of the Homework 1 vs Homework 2 - numerical vs numerical
plot_6 <- ggplot(sub_grade_500, aes(x = homework_1, y = homework_2)) + geom_point() +
  labs(x = "Homework 1", y = "Homework 2", title = "Scatter Plot of HW1 vs HW2 (Class ID = 500)")

# Scatter plot of the exam vs quiz score of class_id 500 - numerical vs numerical
plot_7 <- ggplot(sub_grade_500, aes(x = score_quiz, y = score_exam)) + geom_point() +
  labs(x = "Quiz Score", y = "Exam Score", title = "Scatter Plot of Quiz vs Exam Scores (Class ID = 500)")

# Plot the Course Grade vs Exam score of class_id 20 - numerical vs numerical
sub_grade_a <- subset(grades13, class_id ==20)
plot_8 <- ggplot(sub_grade_a, aes(x = score_exam, y = coursegrade)) + geom_point() +
  labs(x = "Exam score", y = "Course Grade", title = "Scatter Plot of Course Grade vs Exam Scores (Class ID = 20)")

# Plot the Course Grade vs Homework mean of class_id 20 - numerical vs numerical
plot_9 <- ggplot(sub_grade_a, aes(x = homework_mean, y = coursegrade)) + geom_point() +
  labs(x = "Homework mean", y = "Course Grade", title = "Scatter Plot of Course Grade vs Homework mean (Class ID = 20)")

#study the correlation between the columns
library(corrgram)
plot_10 <- corrgram(grades13)

##Machine Learning 
#Supervised machine learning - linear regression 
#Split the data into Train and Test set
library(caTools)
#set a seed
set.seed(101)
#Split up the sample
sample <- sample.split(grades13$score_exam, SplitRatio = 0.7)
# 70% of the data -> Train
train <- subset(grades13, sample == TRUE)
# 30% will be test
test <- subset(grades13, sample == FALSE)

#Train and build model
model <- lm (score_quiz ~ homework_1 + homework_2 , data = train)

# Residual plot
res <- residuals(model)
class(res)
res <- as.data.frame(res)

ggplot(res, aes(res)) + geom_histogram( fill= 'lightblue', alpha = 0.5)
#Interpret the model 
summary(model)

# Prediction 
score_exam.predictions <- predict(model, test)
training_results <- cbind(score_exam.predictions, test$score_exam)
colnames(training_results) <- c('predicted', 'actual')
training_results <- as.data.frame(training_results)

# Root mean square error
mse <- mean((training_results$actual - training_results$predicted)^2)
print(mse^0.5)

#Train and build model
model2 <- lm (score_exam ~ score_quiz * homework_1 * homework_2 , data = train)

# Residual plot
res2 <- residuals(model2)
class(res2)
res2 <- as.data.frame(res2)

ggplot(res2, aes(res2)) + geom_histogram( fill= 'lightblue', alpha = 0.5)
#Interpret the model 
summary(model2)

# Prediction 
score_exam.predictions <- predict(model2, test)
training_results2 <- cbind(score_exam.predictions, test$score_exam)
colnames(training_results2) <- c('predicted', 'actual')
training_results2 <- as.data.frame(training_results2)
# Root mean square error
mse <- mean((training_results2$actual - training_results2$predicted)^2)
print(mse^0.5)


#Unsupervised machine learning - k mean clustering 
head(grades14)
sub_grade_k <- subset(grades14, student_id<=5)
#EDA 
plot_k <- ggplot(sub_grade_k, aes(coursegrade, homework_mean, color = student_id)) + geom_point()

