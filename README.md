# Student Grades Analysis

## Overview
This R project analyzes student grades data from a MongoDB database. It includes data retrieval, transformation, visualization, and machine learning techniques to explore the relationships between different types of assessments (homework, quizzes, exams) and to predict student performance.

## Technologies Used
- R programming language
- MongoDB (for data storage)
- Libraries:
  - `mongolite` for connecting to MongoDB
  - `tidyverse` for data manipulation and visualization
  - `ggplot2` for creating plots
  - `corrgram` for visualizing correlation matrices
  - `caTools` for splitting data into training and testing sets

## Data Transformation

The project transforms the raw data by:

- **Unnesting** the scores for different assessment types (homework, quiz, exam).
- **Pivoting** the data into a wide format.
- **Calculating** homework means and overall course grades.
- **Assigning** letter grades based on the course grade.

## Data Visualization

Various visualizations are generated to analyze the data:

- **Stacked bar plots** for categorical vs. categorical comparisons.
- **Histograms** for the distribution of exam scores.
- **Boxplots** for examining score distributions across classes.
- **Scatter plots** to study relationships between different scores.

## Machine Learning

### Supervised Learning

Two linear regression models are built to predict:

- Quiz scores based on homework scores.
- Exam scores based on quiz and homework scores.

The models are evaluated using root mean square error (RMSE).

### Unsupervised Learning

K-means clustering is performed to explore the relationships between course grades and homework means.

## Usage

Run the R script to execute the data retrieval, transformation, visualization, and machine learning steps. Ensure that you have the necessary access to the MongoDB database and the required libraries installed.


