# Melodica Music Store Business Intelligence Project

![Melodica Logo](https://github.com/SpathisDim/Melodica-Music-Store-Project/assets/74098652/3c46bc32-1046-4c06-9794-cc44dd38a54b)

## Table of Contents
- [Introduction](#introduction)
- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Deliverables](#deliverables)

## Introduction
**Melodica Media Corp.** is a multinational company headquartered in California, USA, that operates the Melodica online music store. The store offers downloadable MP4 files of songs, and customers can purchase and download individual tracks. 

This repository contains the source code and documentation for the **Business Intelligence (BI) Pipeline** created for Melodica to streamline sales analysis, support decision-making, and improve business operations.

## Project Overview
The goal of this project is to design and implement a **Business Intelligence (BI) pipeline** that:
1. Extracts data from the Online Transaction Processing (OLTP) system.
2. Loads data into a Staging Area.
3. Transforms the data into a Data Warehouse (DW) for reporting and analysis.

The final output includes a Power BI report for Melodica's management, which is connected to the data warehouse and provides real-time sales analytics and insights.

## Objectives
- Build an automated **ETL (Extract, Transform, Load)** pipeline to manage sales data from the OLTP database.
- Develop a **Data Warehouse** using either a Star or Snowflake Schema to support historical data and incremental updates.
- Implement **Slowly Changing Dimensions (SCD) Type 2** for customer-related data to preserve historical changes.
- Create **Power BI dashboards** to provide visual insights on sales performance, top-selling tracks, customer behaviour, and more.
- Deploy the entire process in the **Azure Cloud**, leveraging services like **Azure Data Factory**, **Azure Databricks**, or other relevant tools.

## Architecture

The BI pipeline is divided into three main components:
1. **OLTP Database**: The source system containing Melodica's transactional sales data.
2. **Staging Area**: A temporary space used to load and transform data before moving it to the Data Warehouse.
3. **Data Warehouse (DW)**: A structured repository where the transformed data is stored using a Star/Snowflake schema.

Key transformations include:
- Incremental loading of new rows (delta loading).
- Maintaining historical data using **SCD Type 2**.
- Aggregating sales data for reporting.

### Data Flow
- **Data Extraction**: Data is extracted from the OLTP database, including sales, customer, and track information.
- **Staging**: Data is temporarily stored and prepared for transformations.
- **Data Warehouse**: The data is transformed and loaded into fact and dimension tables, with historical data tracked.
- **Reporting**: The Power BI dashboard connects to the data warehouse, enabling visual reports on sales performance.

## Technologies Used
- **SQL Server**: For staging and data warehouse storage.
- **Azure Data Factory**: To automate the ETL pipeline.
- **Azure Databricks**: For data transformation and processing.
- **Power BI**: For generating reports and dashboards.
- **Azure Cloud Services**: Hosting the entire solution.

## Features
- **Automated ETL Pipeline**: Extract, transform, and load data from OLTP to the Data Warehouse.
- **Historical Data Management**: SCD Type 2 implementation for tracking historical changes in customer data.
- **Incremental Loading**: Efficiently loads new and updated records.
- **Power BI Dashboards**: Real-time visualizations for sales tracking and analysis.
  - Top-selling tracks
  - Monthly/annual sales trends
  - Customer demographics and purchasing behaviour

## Installation

### Prerequisites
- Azure subscription with access to **Data Factory**, **Databricks**, **SQL Server**, and **Power BI**.
- Access to the OLTP database backups.

### Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/rotask/Melodica-Music-Store-Project.git
   ```
2. Set up the OLTP database using the provided backup files from the `/DW backup files/` directory.
3. Run the SQL scripts located in the `/Source codes/` directory to create the staging and data warehouse structures.
4. Set up **Azure Data Factory** pipelines for automated ETL.
5. Deploy the Power BI report using the `.pbix` file provided in the `/Power BI/` folder.

## Usage
- Use **Azure Data Factory** or other pipeline tools to automate data ingestion and transformation.
- Access **Power BI** dashboards to visualize key insights on sales performance, top-selling tracks, and customer behaviour.
  
### Sample Power BI Visualizations:
- Sales by track/album/artist
- Customer demographic insights
- Sales trends over time

## Deliverables
The following items are included in this repository:
1. **SQL Scripts**: For creating the staging area, data warehouse, and implementing incremental loads.
2. **ETL Pipeline**: Azure Data Factory pipeline for automating data extraction and transformation.
3. **Power BI Report**: Dashboard for sales analytics connected to the data warehouse.
4. **Project Presentation**: Detailed explanation of the architecture, decisions made, and future improvements.
5. **Backup Files**: Backups of the OLTP and Data Warehouse databases for reference.
