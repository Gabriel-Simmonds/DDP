shinyUI(
	pageWithSidebar(
		headerPanel("Price calculator for OTC European Options on 6 US stocks"),
		sidebarPanel(
            # Choose a company from a choice of 6 companies
			selectInput("company", "Company name:", choices = 
                            c("Boeing (BA)" = "BA", "Ford Motor (F)" = "F", "Tiffany (TIF)" = "TIF", 
                              "United Airlines (UAL)" = "UAL", "Uranium Energy (UEC)" = "UEC", 
                              "3M (MMM)" = "MMM"), selectize = TRUE),
            # Choose an analysis date for pricing your option
			dateInput("t", "Analysis date:", value = "2010-01-01", min = "2010-01-01", 
                      max = Sys.Date() - 1, format = "yyyy-mm-dd", startview = "month", 
                      weekstart = 1, language = "en"),
            # Choose an expiry date for the option
            # This date must be after the analysis date
            # If the expiry date is before or equal to the analysis date, then
            # it is set to be equal to the day after the analysis date in the 
            # output.
			dateInput("T", "Option expiry date:", value = Sys.Date(), min = 
                          "2010-01-02", max = NULL, format = "yyyy-mm-dd", startview = 
                          "month", weekstart = 1, language = "en"),
            # Choose the strike price of the option in US dollars
            # This price can be any price equal to or more than US$ 0.01
			numericInput("k", "Strike price (US$):", value = 0.01, min = 0.01),
            # Select the risk free interest rate in percentage terms.
            # The choice of values available is from 0.1 percent to 5% at 
            # intervals of 0.1%
			selectInput("r", "Risk free rate (%):", choices = 
                            seq(from = 0.0, to = 5.0, by = 0.1)),
            # Select whether this option is a "Put" or a "Call" type option
			selectInput("optionType", "Option type:", choices = c("Put", "Call"), 
                        selectize = TRUE),
            # Press this button once you have made all your choices, and the 
            # price value will be generated in the output
			actionButton("goButton", "Submit")
		),
		mainPanel(
		    p("Documentation:", a("Click here for instructions", href = "helpFile.html")),
			h4("Results of calculation:"),
            # This displays the ticker code of the company selected in the input
			h5("Company ticker code = "), verbatimTextOutput("company"),
			# This displays the analysis date selected in the input
			h5("Analysis date = "), verbatimTextOutput("t"),
			# This displays the expiry date selected in the input
			h5("Expiry date = "), verbatimTextOutput("T"),
			# This displays the strike price selected in the input
			h5("Strike price (US$) = "), verbatimTextOutput("k"),
			# This displays the risk free interest rate selected in the input
			h5("Risk free rate (%) = "), verbatimTextOutput("r"),
			# This displays the type of option (Put or Call) selected in the input
			h5("Option type = "), verbatimTextOutput("optionType"),
			# This displays the option price calculated from the choices made in 
            # the  input
			h5("Giving an option price of "), verbatimTextOutput("optionPrice"),
			# This displays a plot of the stock price of the company selected in 
            # the input, over the period from the start of 2009 until yesterday
			plotOutput("timePlot")
		)
	)
)