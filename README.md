Inequality in Compensation between CEO and employees among top 3000 companies (Russell 3000 & SP 500)

Objective

To uncover the disproportionate relationship between CEO Salary and worker pay in top companies by industry clusters and raise awareness of 
wage inequality for typical employees.

Prepare Data

Dataset was downloaded from Kaggle (https://www.kaggle.com/datasets/salimwid/latest-top-3000-companies-ceo-salary-202223)
Data Souce: The American Federation of Labor and Congress of Industrial Organizations (AFL-CIO)
Data Columns:
- Company name
- CEO name
- CEO salary
- Industry
- Company Ticker
- Median worker pay
- Pay ratio
Datasets were compiled and merged into one single cvs file for data processing. 
Data cleaning included eliminating duplicate row and white spaces, data points with ride duration <=0, rows with null values in bike start or return location. 
4 outliers were removed in the long ride length's range after the outlier test. 
A number of outliers were kept in the data until they could be inspected and invalidated by the company. 

Process Data

DBbrowser for SQLite was used to process the dataset. 
All SQL codes written for data processing and analysis are documented in "ceo_worker_pay_2023.sql" file uploaded in this repository. 
Link: https://github.com/riiitalam/ceo-worker-pay/commit/fb722f4c347dd0d044657d663bc050dbc4665c11

Analyse Data

To analyze bike usage, ride duration is an important factor. A new column 'ride duration' was calculated from ride start time and end time and added to dataset. Top bike stations and top routes were ranked using SQL for analysis. Ride dates are classified into weekend / weekday and added as an additional column for usage comparison. Finalized datasets were imported into Tableau and visualized with various plots. Trends, patterns and relationships were identified and documented in the powerpoint presentation - https://docs.google.com/presentation/d/1eEnF-cGVGcZ82xgQ-yo-QwpkRvO9sdm6fwXs-wqbA-o/edit?usp=sharing

Share Findings

Result of analysis is presented in the interactive Tableau visualization dashboard at 
[https://public.tableau.com/app/profile/rita.lam ](https://public.tableau.com/app/profile/rita.lam/viz/InequalityBetweenExecutiveSalaryWorkerWage/Dashboard1)

Act Phase


