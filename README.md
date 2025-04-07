# 💡 Household Energy Consumption Analysis

## 🔍 Project Overview
This project focuses on analyzing household energy consumption to predict energy demand, understand the impact of temperature on electricity usage, and explore strategies for energy conservation. The study primarily targets energy consumption trends in **July**, emphasizing peak demand scenarios due to high temperatures.

## 📂 Files Included
- ⭐ **`final_report.pdf`** - The complete project report detailing data sources, methodology, and findings.
- 📈 **Processed Data Files** - Merged datasets from house data, electricity consumption, and weather information.

## 🔄 Data Sources
- **Static House Data** - Includes essential identifiers (building ID, county) linked to energy usage.
- **Electricity Consumption Data** - Hour-by-hour energy consumption per household.
- **Weather Data** - Temperature records to analyze energy demand correlation.

## 🎨 Methodologies Implemented
1. **Data Preprocessing & Merging**
   - Consolidation of household static data, energy consumption, and weather data.
   - Feature engineering to enhance predictive capabilities.

2. **Exploratory Data Analysis**
   - Identified key energy consumption drivers.
   - Feature importance analysis using **Random Forest**.

3. **Energy Consumption Modeling**
   - **Panel Data Regression** with fixed effects for county-level analysis.
   - **Linear Regression Model** with temperature, time, and location as independent variables.
   - **Forecasting Future Demand** under increased temperature scenarios (+5°C scenario).

4. **Energy Conservation Strategies**
   - Investigated the role of insulation and HVAC efficiency.
   - Explored the feasibility of modifying consumption patterns.

## 🛠 Tools & Technologies
- **R** (Data processing & statistical modeling)
- **Parquet & CSV files** (Data storage & retrieval)
- **Amazon S3** (Cloud-hosted datasets)
- **Regression & Machine Learning Models** (Random Forest, Panel Data, Linear Regression)

## ⚙️ Setup Instructions
1. Clone the repository:
   ```sh
   git clone https://github.com/ayushsaseendran/household_energy_consumption.git
   ```
2. Install required R packages:
   ```r
   install.packages(c("tidyverse", "randomForest", "data.table", "readr"))
   ```
3. Run the data processing and analysis scripts in RStudio or Jupyter Notebook (with R kernel).

## 🔬 Key Findings
✅ **Energy Demand Prediction**: A **12.5% increase** in electricity demand for a 5°C rise in temperature.  
✅ **Feature Importance**: **Floor area, HVAC efficiency, and insulation quality** significantly impact energy use.  
✅ **Daily & Hourly Trends**: Peak energy usage at **6 PM**, lowest at **10 AM**.  
✅ **Policy Implications**: Smart pricing strategies can help regulate demand and promote energy conservation.  

## 👨‍💻 Contributors
- **Ayush Saseendran** (Data Transformation, Shiny App Development)
- **Francisco Franco Arenas** (Pipeline Design, Model Development, Feature Engineering)
- **Collin Joseph Kneiss** (Project Design, Presentation, Industry Collaboration)
- **Prakruti Pruthvi Kumar** (Shiny App & Presentation Development)

## 📞 Questions?
Feel free to raise an issue or contact the contributors!

---
