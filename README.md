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
Data was checked for duplicate row, white spaces and zero or null values. Special characters was removed from the industry column. 
Also checked ceo_data_pay_merged_r3000 dataset is inclusive of all data from ceo_data_pay_merged_sp500 since Russell 3000 index include SP500 companies. 
3 row with zero values are found and updated accordingly. Avg worker pay is used to update if median value is not found on reliable salary report sites.
Data row for Safehold is removed since median worker pay could not be looked up. 
Reassigned row number since a data entry was removed. 
Also checked and casted appropriate data types for each column.
Checked for outliers and updated two values in worker_median_pay. 
Added category column- SP500 to identify if the company is an SP500 also.

Process Data

DBbrowser for SQLite was used to process the dataset. 
All SQL codes written for data processing and analysis are documented in the "ceo_worker_pay_2023.sql" file uploaded in this repository. 
Link: https://github.com/riiitalam/ceo-worker-pay/commit/fb722f4c347dd0d044657d663bc050dbc4665c11

Analyse Data

To analyze bike usage, ride duration is an important factor. A new column 'ride duration' was calculated from ride start time and end time and added to dataset. Top bike stations and top routes were ranked using SQL for analysis. Ride dates are classified into weekend / weekday and added as an additional column for usage comparison. Finalized datasets were imported into Tableau and visualized with various plots. Trends, patterns and relationships were identified and documented in the powerpoint presentation - https://docs.google.com/presentation/d/1eEnF-cGVGcZ82xgQ-yo-QwpkRvO9sdm6fwXs-wqbA-o/edit?usp=sharing

Share Findings

Result of analysis is presented in the interactive Tableau visualization dashboard at 
[https://public.tableau.com/app/profile/rita.lam ](https://public.tableau.com/app/profile/rita.lam/viz/InequalityBetweenExecutiveSalaryWorkerWage/Dashboard1)

Act Phase
Regulations of executive salary should be implemented 

