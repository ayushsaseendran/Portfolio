# Install required packages if not already installed
# install.packages(c("shiny", "dplyr", "ggplot2", "writexl", "lubridate", "readxl", "forecast"))

# Load required libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(writexl)
library(lubridate)
library(readxl)
library(forecast)

# Read the data from the output_pred_data.xlsx file
pred_data <- read_xlsx("output_pred_data.xlsx")

# Convert the "hour" variable to numeric
pred_data$hour <- as.numeric(as.character(pred_data$hour))

# Create a mapping for numeric values to weekdays
day_mapping <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

# Replace numeric values with corresponding weekdays
pred_data$day_of_week <- day_mapping[as.numeric(as.character(pred_data$day_of_week))]

# Define the UI
ui <- fluidPage(
  titlePanel("Electricity Consumption Explorer"),
  sidebarLayout(
    sidebarPanel(
      # County selection dropdown
      selectInput("county", "Select County", choices = unique(pred_data$`County Name`)),
      
      # Day of the week selection dropdown
      selectInput("day_of_week", "Select Day of Week", choices = unique(pred_data$day_of_week))
    ),
    mainPanel(
      # Plot output
      plotOutput("electricity_plot")
    )
  )
)

# Define the server logic
server <- function(input, output) {
  # Filter data based on user inputs
  filtered_data <- reactive({
    pred_data %>%
      filter(`County Name` == input$county, day_of_week == input$day_of_week)
  })
  
  # Plot the smoothed electricity consumption line
  output$electricity_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = hour, y = total_electricity)) +
      geom_smooth(se = FALSE) +  # Add smoothing line without confidence interval
      labs(title = paste("Smoothed Electricity Consumption for", input$county, "on", input$day_of_week),
           x = "Hour of Day", y = "Total Electricity Consumption")
  })
}

# Run the Shiny app
shinyApp(ui, server)
